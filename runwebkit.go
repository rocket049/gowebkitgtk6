package gowebkitgtk6

/*
#include <stdlib.h>
#include "webkit6go.h"

extern void file_select_dialog(const gchar* title,
                             const gchar* patten,
                             const gchar* start);

extern void folder_select_dialog (const gchar* title,
                               const gchar* start);

extern void file_save_dialog (const gchar* title,
                               const gchar* start);

*/
import "C"

// create application window
func AppCreate(id, title, url string) {
	id1 := C.CString(id)
	title1 := C.CString(title)
	url1 := C.CString(url)

	C.app_create_app(id1, title1, url1)
}

// run application
func AppRun() int {
	status := C.app_run_app()
	return int(status)
}

// quit the app
func AppQuit() {
	C.app_quit()
}

// call gtk dialog to select a file
func AppSelectFile(title, mimeType, startPath string) chan string {
	ret := make(chan string)
	fileChan = ret

	C.file_select_dialog(C.CString(title),
		C.CString(mimeType),
		C.CString(startPath),
	)

	return ret
}

// call gtk dialog to select a folder
func AppSelectFolder(title, startPath string) chan string {
	ret := make(chan string)
	folderChan = ret

	C.folder_select_dialog(C.CString(title),
		C.CString(startPath))
	return ret
}

// call gtk dialog to save a file
func AppFileSave(title, startPath string) chan string {
	ret := make(chan string)
	saveChan = ret

	C.file_save_dialog(C.CString(title),
		C.CString(startPath))
	return ret
}

// user can extend the Gtk ability with this pointer
func GetApplication() *C.GtkApplication {
	return C.app_get_application()
}

// user can extend the Gtk ability with this pointer
func GetWindow() *C.GtkWindow {
	return C.app_get_window()
}

// user can extend the WebKit ability with this pointer
func GetWebView() *C.WebKitWebView {
	return C.app_get_webview()
}

// resize window
func AppResize(w, h int) {
	C.app_resize(C.int(w), C.int(h))
}

// show inspector
func AppShowInspector() {
	C.app_show_inspector()
}
