function filenames = dirGetFiles(dirname)
    contents = dir(dirname);
    filenames = {contents.name};
end