package lib

import (
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"mime"
)

func IsFilePresent(filesystem fs.FS, filename string) (bool, error) {
	found := false
	walkFn := func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.Name() == filename && !d.IsDir() {
			found = true
			return fs.SkipAll
			// return fs.SkipDir
		}
		return nil
	}
	err := fs.WalkDir(filesystem, ".", walkFn)
	if err != nil {
		return false, err
	}
	return found, nil
}

func CreateEmptyFileIfNotExists(filename string) (string, error) {
	err := os.MkdirAll(filepath.Dir(filename), 0700)
	if err != nil {
		return "", err
	}
	filetry, err := os.Open(filename)
	filetry.Close()
	if os.IsNotExist(err) {
		file, err := os.Create(filename)
		defer file.Close()
		if err != nil {
			return "", err
		}
		err = file.Chmod(0600)
		if err != nil {
			return "", err
		}
	} else if err != nil {
		return "", err
	}
	absPath, err := filepath.Abs(filename)
	if err != nil {
		return "", err
	}
	return absPath, nil
}

func ContentTypeFromExt(ext string) (string, error) {
	contentType := mime.TypeByExtension(ext)
	if contentType != "" {
		return contentType, nil
	}
	switch ext {
	case ".txt":
		return "text/plain", nil
	case ".woff":
		return "font/woff", nil
	case ".woff2":
		return "font/woff2", nil
	case ".ttf":
		return "font/ttf", nil
	case ".gz":
		return "application/gzip", nil
	case ".eot":
		return "application/vnd.ms-fontobject", nil
	case ".otf":
		return "font/otf", nil
	case ".mp4":
		return "video/mp4", nil
	case ".webm":
		return "video/webm", nil
	case ".ogg":
		return "audio/ogg", nil
	case ".mp3":
		return "audio/mpeg", nil
	default:
		return "", errors.New("Unknown extension: " + ext)
	}
}

func MapSlice[T any, V any](list []T, f func(T) V) []V {
	ret := []V{}
	for _, item := range list {
		ret = append(ret, f(item))
	}
	return ret
}

func FilterSlice[T any](list []T, f func(T) bool) []T {
	ret := []T{}
	for _, item := range list {
		if f(item) {
			ret = append(ret, item)
		}
	}
	return ret
}

func FilterMapSlice[T any, V any](list []T, m func(T) V, f func(T) bool) []V {
	ret := []V{}
	for _, item := range list {
		if f(item) {
			ret = append(ret, m(item))
		}
	}
	return ret
}

func MapMap[T comparable, V any, R any](m map[T]V, f func(T, V) R) map[T]R {
	ret := make(map[T]R)
	for k, v := range m {
		ret[k] = f(k, v)
	}
	return ret
}

func FilterMap[T comparable, V any](m map[T]V, f func(T, V) bool) map[T]V {
	ret := make(map[T]V)
	for k, v := range m {
		if f(k, v) {
			ret[k] = v
		}
	}
	return ret
}

func FilterMapMap[T comparable, V any, R any](m map[T]V, function func(T, V) R, filter func(T, V) bool) map[T]R {
	ret := make(map[T]R)
	for k, v := range m {
		if filter(k, v) {
			ret[k] = function(k, v)
		}
	}
	return ret
}
