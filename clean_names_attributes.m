function newVarName=clean_names_attributes(varName)
% Takes any string, and cleans it up such that it can be used as a
% fieldname in a matlab structure. For instance, :, -, and prefixed _ are
% removed.
tmp = regexprep(varName,'\s','_');
tmp = regexprep(tmp,'^_+','');
newVarName= regexprep(tmp,'-','_');
end
