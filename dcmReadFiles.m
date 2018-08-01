function [im, units] = dcmReadFiles(filenames)
% Call imRead3D on the specified DICOM files. Uses links rather than copies

% Link all of the files in a new directory, call imRead3D on that
tempDirName = tempname;
mkdir(tempDirName)
try
    for j = 1 : length(filenames)
        filename = filenames{j};
        assert(exist(filename, 'file') > 0)
        tempLinkName = fullfile(tempDirName, [num2str(j) '.dcm']);
        assert(system(['ln -s ' filenames{j} ' ' tempLinkName]) == 0)
    end
    
    % Read the file
    [im, units] = imRead3D(tempDirName);
catch ME
    rmdir(tempDirName, 's')
    rethrow(ME)
end
rmdir(tempDirName, 's')

end