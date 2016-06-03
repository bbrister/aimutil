function dcmName = aimGetDicom(aimName, dcmRoot, lutName)
%aimGetDicom given an aim file and a directory containing DICOM files,
%return the name of the DICOM file annotated by the provided AIM file. The
%optional "lut" argument allows the use of a lookup table to accelerate
%DICOM searching. If the file is not in the LUT, but found by searching
%dcmDir, this function will add it to the LUT.

% Verify inputs
if nargin < 1 || isempty(aimName)
    error('aimName not specified')
end

if ~isa(aimName, 'char')
    error('aimName must be a string')
end

if nargin < 2 || isempty(dcmRoot)
    error('dcmDir not specified')
end

if ~isa(dcmRoot, 'char')
    error('dcmDir must be a string')
end

% Default arguments
if nargin < 3
    lutName = [];
end

if ~isempty(lutName) && ~isa(lutName, 'char')
    error('lutName must be a string')
end

% Add jjvector to the path
addpath(jjPath());

% Define the basic AIM path components
xml_filter_annotation = {
    'ImageAnnotationCollection'
    'imageAnnotations'
    'ImageAnnotation'
    };
xml_filter_imageReference = {
    'imageReferenceCollection'
    'ImageReference'
    };
xml_filter_imageReferenceEntity = {
    'imageReferenceEntityCollection'
    'ImageReferenceEntity'
    };
xml_filter_study = {
    'study'
    'Study'
    };
xml_filter_series = {
    'series'
    'Series'
    };
xml_filter_imageStudy = {
    'imageStudy'
    'ImageStudy'
    };
xml_filter_imageSeries = {
    'imageSeries'
    'ImageSeries'
    };
xml_filter_image = {
    'imageCollection'
    'Image'
    };


% Variants of equivalent compoenets for different AIM versions
xml_filter_reference_group = {
    xml_filter_imageReference
    xml_filter_imageReferenceEntity
    };
xml_filter_studySeries_group = {
    [
    xml_filter_study 
    xml_filter_series
    ]
    [
    xml_filter_imageStudy 
    xml_filter_imageSeries
    ]
    };

% Try each combination of equivalent queries
SOPInstanceUID = [];
xmlDoc = parseXML(aimName);
for i = 1 : length(xml_filter_reference_group)
    for j = 1 : length(xml_filter_studySeries_group)
        xml_filter = [
            xml_filter_annotation
            xml_filter_reference_group{i}
            xml_filter_studySeries_group{j}
            xml_filter_image
            ];
        SOPInstanceUID = getUID(xmlDoc, xml_filter);
        if ~isempty(SOPInstanceUID)
            break;
        end
    end
end
if isempty(SOPInstanceUID)
    error('Failed to read SOPInstanceUID');
end

% Load the file lookup table
if isempty(lutName) || ~exist(lutName, 'file')
    % Create a blank LUT
    lut = DicomLUT;
else
    % Load the LUT from the specified file, should have the variable name
    % "lut"
    lut = loadLUT(lutName);
end

% Check if this file is in the LUT
dcmLUTNames = lut.lookup(SOPInstanceUID);
if isempty(dcmLUTNames)
    
    % Search for the DICOM file
    dcmName = dcmSearchDir(dcmRoot, SOPInstanceUID);
    if (isempty(dcmName))
        error(['No matching DICOM file for ' aimName ' found in ' ...
            dcmRoot]);
    end
    
    % Optionally update the LUT
    if ~isempty(lutName)
        
        % NOTE: A proper implementation would use file or process locks to 
        % ensure that no updates can be lost. Since MATLAB does not support 
        % this, the following approach is good enough to drastically reduce
        % the chance of losing an update. Note that, if an update is lost, 
        % the LUT will not be invalid, but rather the work of finding that 
        % file will simply need to be redone
        
        % The name of the lock file
        lockName = fullfile(tempName(), 'lock.mat');
        
        % Try to acquire a lock
        waitRange = [2 10];
        pause(min(rand() * max(waitRange), min(waitRange)));
        while exist(lockName, 'file')   
            % Print a message saying this worker is waiting
            worker = getCurrentWorker();
            workerName = 'default';
            if ~isempty(worker)
                workerName = worker.name;
            end
            disp(['Worker ' workerName() ' waiting for LUT access...']);
            
            % Wait a random amount of time
            pause(min(rand() * max(waitRange), min(waitRange)));
        end
        
        % Acquire the lock
        lock = true;
        save(lockName, 'lock');
        
        try
            % Reload the LUT, if it exists
            if exist(lutName, 'file')
                lut = loadLUT(lutName);
            end
            
            % Add the entry
            lut = lut.add(dcmName, SOPInstanceUID);
            
            % Check that the entry can be retrieved
            assert(numel(lut.probe(dcmName, SOPInstanceUID)) == 1);
            assert(~isempty(lut.lookup(SOPInstanceUID)));
            
            % Save the new LUT
            save(lutName, 'lut');
        catch ME
            % Release the lock and error out
            delete(lockName);
            rethrow(ME)
        end
        
        % Release the lock
        delete(lockName);
    end
    
elseif (numel(dcmLUTNames) > 1)
    error(['Multiple matches in LUT for file ' aimName ...
        ', SOPInstanceUID ' SOPInstanceUID])
else
    % Valid LUT hit
    dcmName = dcmLUTNames{1};
end

% Restore the path
rmpath(jjPath());

end

function uid = getUID(xmlDoc, xml_filter)
    % Helper function to parse the XML file
    uid = parseDoc(xmlDoc, xml_filter, 'SOPInstanceUID', 1);
    if isempty(uid)
        uid = parseDoc(xmlDoc, [xml_filter; {'sopInstanceUid'}], ...
            'root', 1);
    end
    if ~isempty(uid)
        uid = uid{1}; 
    end
end