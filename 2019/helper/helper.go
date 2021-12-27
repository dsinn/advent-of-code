package helper

import (
	"bufio"
	"io"
	"io/ioutil"
	"os"
	"path"
	"regexp"
	"runtime"
	"strings"
)

func GetAllInputText() string {
	bytes, err := ioutil.ReadFile(getInputFilePath())
	if err != nil {
		panic(err)
	}
	return strings.TrimRight(string(bytes), "\n")
}

func GetInputLineChannel() chan string {
	file, err := os.Open(getInputFilePath())
	if err != nil {
		panic(err)
	}

	channel := make(chan string)
	reader := bufio.NewReader(file)
	go func() {
		for {
			line, _, err := reader.ReadLine()
			if err != nil {
				file.Close()
				close(channel)
				if err != io.EOF {
					panic(err)
				}
				return
			}
			channel <- string(line)
		}
	}()

	return channel
}

func getInputFilePath() string {
	regexFileExtension := regexp.MustCompile("\\.[^.]+$")
	_, filename, _, _ := runtime.Caller(2)
	return path.Join(path.Dir(filename), regexFileExtension.ReplaceAllString(path.Base(filename), ".txt"))
}
