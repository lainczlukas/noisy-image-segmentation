clear all;clc;
in=input('enter an image to segment','s');
IM=imread(in);
IM=double(IM);
figure(1)
imshow(uint8(IM))
[maxX,maxY]=size(IM);
IMM=cat(3,IM,IM);

%inicializacia stredov zhlukov
cc1=0;
cc2=255;

%FCM algoritmus inšpirovaný - https://www.mathworks.com/matlabcentral/fileexchange/25532-fuzzy-c-means-segmentation

ttFcm=0;
while(ttFcm<15)
    ttFcm=ttFcm+1;
    
    c1=repmat(cc1,maxX,maxY);
    c2=repmat(cc2,maxX,maxY);

    c=cat(3,c1,c2);
    
    ree=repmat(0.000001,maxX,maxY);
    ree1=cat(3,ree,ree);
    
    distance=IMM-c;
    distance=distance.*distance+ree1;
    
    daoShu=1./distance;
    
    %vypocet miery prislusnosti
    daoShu2=daoShu(:,:,1)+daoShu(:,:,2);
    distance1=distance(:,:,1).*daoShu2;
    u1=1./distance1;
    distance2=distance(:,:,2).*daoShu2;
    u2=1./distance2;
    % vypocet stredu noveho zhluku
    ccc1=sum(sum(u1.*u1.*IM))/sum(sum(u1.*u1));
    ccc2=sum(sum(u2.*u2.*IM))/sum(sum(u2.*u2));
    % vypocet zmeny
    accuracy=[abs(cc1-ccc1)/cc1,abs(cc2-ccc2)/cc2];
    pp=cat(3,u1,u2);
    %segmentacia obrazu
    for i=1:maxX
        for j=1:maxY
            if max(pp(i,j,:))==u1(i,j)
                IX2(i,j)=1;
           
            else
                IX2(i,j)=2;
            end
        end
    end

   if max(accuracy)<0.0001
         break;
  else
         cc1=ccc1;
         cc2=ccc2;
        
   end

  cA = round(ccc1);
  cB = round(ccc2);
 for i=1:maxX
       for j=1:maxY
            if IX2(i,j)==2
            IMMM(i,j)=cB;
                 else
            IMMM(i,j)=cA;
            end
        end
end

figure(2);
imshow(uint8(IMMM));
tostore=uint8(IMMM);
imwrite(tostore,'images/fuzzysegmented.jpg');
end

disp('The final cluster centers are');
ccc1
ccc2

IMs = IMMM;
IMhelp = zeros(maxX,maxY);

    % odstranovanie šumu zo segmentovaneho obrazu
     for i=1:2
        for i=2:maxX-1
            for j=2:maxY-1
                dN = 0;
                if IMs(i,j) == cA
                    if (IMs(i,j+1) == cB && IMs(i,j-1) == cB) || (IMs(i+1,j) == cB && IMs(i-1,j) == cB)
                        IMs(i,j) = cB;
                        % uloženie pozicie šumu
                        IMhelp(i,j) = 1;
                    end
                end
                if IMs(i,j) == cB
                    if (IMs(i,j+1) == cA && IMs(i,j-1) == cA) || (IMs(i+1,j) == cA && IMs(i-1,j) == cA)
                        IMs(i,j) = cA;
                        % uloženie pozície šumu
                        IMhelp(i,j) = 1;
                    end
                end
            end
        end
     end  
     
figure(3);
imshow(uint8(IMs));
tostore=uint8(IMs);
imwrite(tostore,'images/fuzzysegmented_denoised.jpg');



IMd = IM;
% čistenie pôvodneho zašumeného obrazu
for i=2:maxX-1
    for j=2:maxY-1
        if IMhelp(i,j) == 1
            IMd(i,j) = (IMd(i-1,j)+IMd(i+1,j)+IMd(i,j-1)+IMd(i-1,j))/4;
        end
    end
end  
    
for i=2:maxX-1
    for j=2:maxY-1
        diff = (IMd(i,j+1)+IMd(i,j-1)+IMd(i+1,j)+IMd(i-1,j))/4;
        if IMd(i,j) - diff > 70
            IMd(i,j) = diff;
        end
    end
end

figure(4);
imshow(uint8(IMd));
tostore=uint8(IMd);
imwrite(tostore,'images/fuzzy_denoised.jpg');
