clc, clear, close all
filename = 'transferfiles.txt';
delimiter = '\t';
startRow = 2;
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[2,3,4,5,6,7,8,9,10,11]
    % 将输入元胞数组中的文本转换为数值。已将非数值文本替换为 NaN。
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % 创建正则表达式以检测并删除非数值前缀和后缀。
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % 在非千位位置中检测到逗号。
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % 将数值文本转换为数值。
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end
rawNumericColumns = raw(:, [2,3,4,5,6,7,8,9,10,11]);
rawStringColumns = string(raw(:, [1,12]));
idx = (rawStringColumns(:, 2) == "<undefined>");
rawStringColumns(idx, 2) = "";
transferfiles = table;
transferfiles.shape = rawStringColumns(:, 1);
transferfiles.x0 = cell2mat(rawNumericColumns(:, 1));
transferfiles.y0 = cell2mat(rawNumericColumns(:, 2));
transferfiles.z0 = cell2mat(rawNumericColumns(:, 3));
transferfiles.alpha = cell2mat(rawNumericColumns(:, 4));
transferfiles.beta = cell2mat(rawNumericColumns(:, 5));
transferfiles.gamma = cell2mat(rawNumericColumns(:, 6));
transferfiles.p1 = cell2mat(rawNumericColumns(:, 7));
transferfiles.p2 = cell2mat(rawNumericColumns(:, 8));
transferfiles.p3 = cell2mat(rawNumericColumns(:, 9));
transferfiles.p4 = cell2mat(rawNumericColumns(:, 10));
transferfiles.filename = categorical(rawStringColumns(:, 2));
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp rawNumericColumns rawStringColumns idx;

% % % build the world
figure(1)
plot3([0 0], [0 0], [0 100], 'k', 'LineWidth', 2)
axis([0 100 0 100 0 100])
hold on 
grid on
plot3([0 100], [0 0], [0 0], 'k', 'LineWidth', 2)
plot3([0 0], [0 100], [0 0], 'k', 'LineWidth', 2)
xlabel('world_x')
ylabel('world_y')
zlabel('world_z')

map_v=zeros(3);
map_f=zeros(3);
sum_a=[0,0];
 for index=1:1:length(transferfiles.shape)
    [map_v_i,map_f_j]=drawobstacle(transferfiles,index);
    
    a(:,:,index)=size(map_v_i);
   
    map_f_j=map_f_j+sum_a(1);
     sum_a=sum_a+a(:,:,index);
    map_v= [map_v;map_v_i];
    map_f= [map_f;map_f_j];
 end

 map_v(1:3,:)=[];
 map_f(1:3,:)=[];
% %build sphere
% 
% [v1,f1] = buildSphere(50,50,50,0,0,0,20,0,0,0,0,0);
% 
% % stlPlot(v1,f1,'Sphere','b');
% 
% %build cylinder
% [v2,f2] = buildCylinder(50,10,10,-90,0,90,20,10,0,0,0,0);
% % stlPlot(v2,f2,'Cylinder','g')
% 
% %build cuboid
% 
% [v3,f3] = buildCuboid(70,70,70,30,30,30,20,30,40,0,0,0);
% % stlPlot(v3,f3,'Cuboid','b');
% 
% % build cone
% [v4,f4] = buildCone(70,40,40,0,0,90,40,20,0,0,0,0);
% % stlPlot(v4,f4,'Cone','g');
% 
% 
% %build stl object
% [v5,f5,name] = buildObject_stl(20,40,20,30,30,30,'femur_binary.stl',0,0,0,0,0);
% stlPlot(v5,f5,name,'r');
% 
% %write out
% v = [v1;v2;v3;v4;v5];
% a1 = size(v1);
% a2 = size(v2);
% a3 = size(v3);
% a4 = size(v4);
% 
% f2 = f2 + a1(1);
% f3 = f3 + a1(1) + a2(1);
% f4 = f4 + a1(1) + a2(1) + a3(1);
% f5 = f5 + a1(1) + a2(1) + a3(1) + a4(1);
% 
% f = [f1;f2;f3;f4;f5];
stlPlot(map_v,map_f,'whole_map','g');

stlWrite('test.stl',map_f,map_v);
 
 
 function [v,f]=drawobstacle(transferfiles,index)
 shape=transferfiles.shape(index);
x0=transferfiles.x0(index);
y0=transferfiles.y0(index);
z0=transferfiles.z0(index);
alpha=transferfiles.alpha(index);
beta=transferfiles.beta(index);
gamma=transferfiles.gamma(index);
p1=transferfiles.p1(index);
p2=transferfiles.p2(index);
p3=transferfiles.p3(index);
p4=transferfiles.p4(index);
p5=transferfiles.filename(index);

    if (shape== 'cubo')
        [v,f]=buildCuboid(x0,y0,z0,alpha,beta,gamma,p1,p2,p3,p4,p5,0);
    elseif (shape== 'cyli')
        [v,f]=buildCylinder(x0,y0,z0,alpha,beta,gamma,p1,p2,p3,p4,p5,0);
    elseif (shape=='cone')
        [v,f]=buildCone(x0,y0,z0,alpha,beta,gamma,p1,p2,p3,p4,p5,0);
    elseif (shape== 'sphe')
        [v,f]=buildSphere(x0,y0,z0,alpha,beta,gamma,p1,p2,p3,p4,p5,0);
    elseif (shape== 'obje')
        [v,f]=buildObject_stl(x0,y0,z0,alpha,beta,gamma,char(p5),p2,p3,p4,p5,0);
    end


 end












