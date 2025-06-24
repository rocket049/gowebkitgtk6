package gowebkitgtk6

import "C"

var saveChan chan string

// Do Not use this
//
//export WriteSavePath
func WriteSavePath(s *C.char) {
	if saveChan != nil {
		saveChan <- C.GoString(s)
	}
}

var fileChan chan string

// Do Not use this
//
//export WriteFilePath
func WriteFilePath(s *C.char) {
	if fileChan != nil {
		fileChan <- C.GoString(s)
	}
}

var folderChan chan string

// Do Not use this
//
//export WriteFolderPath
func WriteFolderPath(s *C.char) {
	if folderChan != nil {
		folderChan <- C.GoString(s)
	}
}
