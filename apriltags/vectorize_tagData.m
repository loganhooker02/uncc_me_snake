function vectorize_tagData(inputFile,outputFile,maxTags)

load(inputFile);
N = video.NumFrames;
tagPosX = ones([N maxTags])*NaN;
tagPosY = tagPosX;
tagPosZ = tagPosX;
for i = 1:N
    % record data over time
    loc = locHist{i};
    id = idHist{i};
    pose = poseHist{i};
    % number of tags in ith frame
    M = length(id);
    for j = 1:1:M
        tagPosX(i,id(j)+1) = pose(j).Translation(1);
        tagPosY(i,id(j)+1) = pose(j).Translation(2);
        tagPosZ(i,id(j)+1) = pose(j).Translation(3);
        R = pose(j).Rotation;
        eul = rotm2eul(R);
        tagYaw(i,id(j)+1) = eul(1);
        tagPitch(i,id(j)+1) = eul(2);
        tagRoll(i,id(j)+1) = eul(3);
    end
end
1;
save(outputFile,"tagPosX","tagPosY","tagPosZ","tagYaw","tagPitch","tagRoll");
end

