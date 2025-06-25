package gowebkitgtk6

import "C"

var saveChan chan string

// Do Not use this
//
//export WriteSavePath
func WriteSavePath(s *C.char) {
	if saveChan != nil {
		saveChan <- C.GoString(s)
		close(saveChan)
		saveChan = nil
	}
}

var fileChan chan string

// Do Not use this
//
//export WriteFilePath
func WriteFilePath(s *C.char) {
	if fileChan != nil {
		fileChan <- C.GoString(s)
		close(fileChan)
		fileChan = nil
	}
}

var folderChan chan string

// Do Not use this
//
//export WriteFolderPath
func WriteFolderPath(s *C.char) {
	if folderChan != nil {
		folderChan <- C.GoString(s)
		close(folderChan)
		folderChan = nil
	}
}

var multiFileChan chan string

// Do Not use this
//
//export WriteMultiFile
func WriteMultiFile(s *C.char) {
	println(s)
	if multiFileChan != nil {
		multiFileChan <- C.GoString(s)
		close(multiFileChan)
		multiFileChan = nil
	}
}

var multiFolderChan chan string

// Do Not use this
//
//export WriteMultiFolder
func WriteMultiFolder(s *C.char) {
	println(s)
	if multiFolderChan != nil {
		multiFolderChan <- C.GoString(s)
		close(multiFolderChan)
		multiFolderChan = nil
	}
}
