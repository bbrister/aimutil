function mkdirIfNotExist(dirName)
%mkdirIfNotExist(dirName) make a directory if it doesn't already exist.

if ~exist(dirName, 'dir')
    mkdir(dirName)
end

end