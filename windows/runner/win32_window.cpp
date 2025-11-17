#include "win32_window.h"

#include <flutter_windows.h>

#include "resource.h"

namespace {

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

void EnableFullDpiSupportIfAvailable(HWND hwnd) {
  bool enabled = false;
  HMODULE user32_module = LoadLibraryA("User32.dll");
  if (!user32_module) {
    return;
  }
  auto get_dpi_for_window = reinterpret_cast<UINT(WINAPI*)(HWND)>(
      GetProcAddress(user32_module, "GetDpiForWindow"));
  if (get_dpi_for_window) {
    enabled = true;
  }
  FreeLibrary(user32_module);
}

}  // namespace

Win32Window::Win32Window() {}

Win32Window::~Win32Window() {
  Destroy();
}

bool Win32Window::Create(const std::wstring& title,
                        const Point& origin,
                        const Size& size) {
  Destroy();

  const wchar_t* window_class = kWindowClassName;

  WNDCLASS window_class_desc = {};
  window_class_desc.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class_desc.lpszClassName = window_class;
  window_class_desc.style = CS_HREDRAW | CS_VREDRAW;
  window_class_desc.cbClsExtra = 0;
  window_class_desc.cbWndExtra = 0;
  window_class_desc.hInstance = GetModuleHandle(nullptr);
  window_class_desc.hIcon = LoadIcon(window_class_desc.hInstance, MAKEINTRESOURCE(IDI_APP_ICON));
  window_class_desc.hbrBackground = 0;
  window_class_desc.lpszMenuName = nullptr;
  window_class_desc.lpfnWndProc = WndProc;
  RegisterClass(&window_class_desc);

  auto* result = CreateWindow(
      window_class, title.c_str(), WS_OVERLAPPEDWINDOW,
      Scale(origin.x, GetDpiForHWND(nullptr)),
      Scale(origin.y, GetDpiForHWND(nullptr)),
      Scale(size.width, GetDpiForHWND(nullptr)),
      Scale(size.height, GetDpiForHWND(nullptr)),
      nullptr, nullptr, GetModuleHandle(nullptr), this);

  if (!result) {
    return false;
  }

  UpdateWindow(result);

  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::Destroy() {
  OnDestroy();

  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

bool Win32Window::OnCreate() {
  return true;
}

void Win32Window::OnDestroy() {}

LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                     UINT const message,
                                     WPARAM const wparam,
                                     LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                    reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));

    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    EnableFullDpiSupportIfAvailable(window);
    that->window_handle_ = window;
  } else if (Win32Window* that = GetThisFromHandle(window)) {
    return that->MessageHandler(window, message, wparam, lparam);
  }

  return DefWindowProc(window, message, wparam, lparam);
}

LRESULT
Win32Window::MessageHandler(HWND hwnd,
                           UINT const message,
                           WPARAM const wparam,
                           LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      window_handle_ = nullptr;
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;

      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top, newWidth,
                  newHeight, SWP_NOZORDER | SWP_NOACTIVATE);

      return 0;
    }
    case WM_SIZE: {
      RECT rect = GetClientArea();
      if (child_content_ != nullptr) {
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                  rect.bottom - rect.top, TRUE);
      }
      return 0;
    }

    case WM_ACTIVATE:
      if (child_content_ != nullptr) {
        SetFocus(child_content_);
      }
      return 0;
  }

  return DefWindowProc(window_handle_, message, wparam, lparam);
}

HWND Win32Window::GetHandle() {
  return window_handle_;
}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame = GetClientArea();

  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
            frame.bottom - frame.top, true);

  SetFocus(child_content_);
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

HWND Win32Window::GetHandle() {
  return window_handle_;
}

Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}
