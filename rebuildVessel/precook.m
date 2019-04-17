clear
iy=repmat(1:512,512,1);
ix=iy';
zP=[];
for i=1:99
    Img=imbinarize(imread(['./img/',sprintf('%02d',i),'.bmp']));
    Edge=bwmorph(Img,'remove');
    Inside=Img-Edge;
    if i==1
        pList_pos=find(Inside==1);
    else
        pList_pos=[];
        for dx=zP(i-1,1)-10:zP(i-1,1)+10
            for dy=zP(i-1,2)-10:zP(i-1,2)+10
                ind=dy*512+dx;
                pList_pos(end+1)=ind;
            end
        end
    end
    pMinR=zeros(length(pList_pos),1);
    for p =1:length(pList_pos)
        px=ix(pList_pos(p));
        py=iy(pList_pos(p));
        Distance=sqrt((ix(Edge)-px).^2+(iy(Edge)-py).^2);
        minR=min(Distance);
        pMinR(p)=minR;
    end
    maxR=max(pMinR);
    maxR_pos=pList_pos(pMinR==maxR);
    cpX=ix(maxR_pos);
    cpY=iy(maxR_pos);
    if length(cpX)>1
        preX=zP(i-1,1);
        prepreX=zP(i-2,1);
        preY=zP(i-1,2);
        prepreY=zP(i-2,2);
        subD=abs((cpX-preX)-(preX-prepreX))+abs((cpY-preY)-(preY-prepreY));
        cpX=cpX(subD==min(subD));
        cpY=cpY(subD==min(subD));
    end
%     imshow(Img);
%     hold on
%     plot(cpY,cpX,'r*');
%     pause(0.1);
    zP(end+1,:)=[cpX(1),cpY(1),3*i,maxR];
end
csvwrite('1.csv',zP)
