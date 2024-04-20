function dat=convert_char_cell(tmp)
% Converting characters arrays as cells
if ischar(tmp)
    dat=char2cell(tmp);
else
    dat=tmp;
end

end
