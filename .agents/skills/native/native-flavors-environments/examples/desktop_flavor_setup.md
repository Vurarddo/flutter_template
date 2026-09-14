# Desktop Multi-Flavor Setup (Linux & Windows)

### 1. Linux Setup

In `linux/CMakeLists.txt`:
```cmake
if(DEFINED FLUTTER_FLAVOR)
  add_definitions(-DFLUTTER_FLAVOR="${FLUTTER_FLAVOR}")
endif()
```

In `linux/my_application.cc`:
```cpp
#ifdef FLUTTER_FLAVOR
  std::string flavor = FLUTTER_FLAVOR;
  if (flavor == "dev") {
    gtk_window_set_title(window, "App Dev");
  } else if (flavor == "stage") {
    gtk_window_set_title(window, "App Staging");
  } else {
    gtk_window_set_title(window, "App");
  }
#else
  gtk_window_set_title(window, "App");
#endif
```

---

### 2. Windows Setup

In `windows/CMakeLists.txt`:
```cmake
if(DEFINED FLUTTER_FLAVOR)
  add_definitions(-DFLUTTER_FLAVOR="${FLUTTER_FLAVOR}")
endif()
```

In `windows/runner/main.cpp`:
```cpp
#ifdef FLUTTER_FLAVOR
  std::string flavor = FLUTTER_FLAVOR;
  std::wstring title = L"App";
  if (flavor == "dev") {
    title = L"App Dev";
  } else if (flavor == "stage") {
    title = L"App Staging";
  }
  if (!window.Create(title, origin, size)) {
    return EXIT_FAILURE;
  }
#else
  if (!window.Create(L"App", origin, size)) {
    return EXIT_FAILURE;
  }
#endif
```
