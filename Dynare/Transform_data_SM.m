data = readtable('D:\Single Author\Github_fresh\Single_Author_fresh\Dynare\SM_Germany_transformed_data.xlsx');

data = table2struct(data, 'ToScalar', true);

save('SM_Germany_transformed_data.mat', '-struct', 'data');