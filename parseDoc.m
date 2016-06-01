function val = ParseDoc(xmlDoc, xml_filter, propertyName, isString)
%parseDoc helper function for XML parsing from jjvector

node{1}=xmlDoc;
res = GetXMLChildPath(node,xml_filter);
if ~isString
    val = [];
else
    val = cell(0);
end
for i = 1 : length(res)
    for j = 1 : length(res{i}.Attributes)
        if strcmp(res{i}.Attributes(j).Name,propertyName)
            tmp = res{i}.Attributes(j).Value;
            if ~isString
                tmp = str2num(tmp);
                val = [val; tmp];
            else
                val{length(val)+1} = tmp;
            end
        end
    end
end