function path = absPath(name)
% Return an absolute file path. This is a ridiculous hack

javaFileObj = java.io.File(name);
path = char(javaFileObj.getCanonicalPath());

end