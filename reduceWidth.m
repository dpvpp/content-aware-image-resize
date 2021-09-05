function [output] = reduceWidth(im,numPixels)
figure
imshow(im),title("image");
G = rgb2gray(im);
[m,n] = size(G);
E = zeros(m,n);
SI = im;
G = im2double(G);
for x = 1:m
    for y = 1:n
        if x == 1
           dx = abs((-G(x,y)+G(x+1,y))/2);
        elseif x == m
           dx = abs((G(x,y)-G(x-1,y))/2);
        else
           dx = abs((G(x,y)-G(x-1,y) - G(x,y)+G(x+1,y))./2);
        end
        if y == 1
           dy = abs((-G(x,y)+G(x,y+1))/2);
        elseif y == n
           dy = abs((G(x,y)-G(x,y-1))/2);
        else
           dy = abs((G(x,y)-G(x,y-1) - G(x,y)+G(x,y+1))./2);
        end
        E(x,y) = dx + dy;
    end
end

figure
imagesc(E),title("Energy Graph");

M = zeros(m,n);
M(1,:) = E(1,:);
for x = 2:m
    for y = 1:n
        if y == 1
            M(x,y) = E(x,y) + min([M(x-1,y) M(x-1,y+1)]);
        elseif y == n
            M(x,y) = E(x,y) + min([M(x-1,y-1) M(x-1,y)]);
        else
            M(x,y) = E(x,y) + min([M(x-1,y-1) M(x-1,y) M(x-1,y+1)]);
        end
    end
end

NM = M;
RI = im;
NE = E;
nn = n;

for j = 1:numPixels
    on = nn;
    nn = nn-1;
    E2 = NE;
    M2 = NM;
    im2 = RI;
    [mn,i] = min(M2(m,:));    
    disp(mn)
    S = zeros(m);
    S(m) = i;
    RI = uint8(zeros(m,nn,3));
    NE = zeros(m,nn);
    NM = zeros(m,nn);
    for x = m:-1:2
        if S(x) == 1
            [mn, i] = min([M2(x-1,S(x)) M2(x-1,S(x)+1)]);
            S(x-1) = S(x)-1+i;
            RI(x,:,:) = im2(x,2:on,:);
            NE(x,:) = E2(x,2:on);
        elseif S(x) == on
            [mn, i] = min([M2(x-1,S(x)-1) M2(x-1,S(x))]);
            S(x-1) = S(x)-2+i;
            RI(x,:,:) = im2(x,1:nn,:);
            NE(x,:) = E2(x,1:nn);
        else
            [mn, i] = min([M2(x-1,S(x)-1) M2(x-1,S(x)) M2(x-1,S(x)+1)]);
            S(x-1) = S(x)-2+i;
            RI(x,:,:) = im2(x,1:on ~=S(x),:);
            NE(x,:) = E2(x,1:on ~=S(x));
        end
    end
    RI(1,:,:) = im2(1,1:on ~=S(1),:);
    NE(1,:,:) = E2(1,1:on ~=S(1),:);
    SI(1,S(1),:) = 255;
    NM(1,:) = NE(1,:);
    for x = 2:m
        for y = 1:nn
            if y == 1
                NM(x,y) = NE(x,y) + min([NM(x-1,y) NM(x-1,y+1)]);
            elseif y == nn
                NM(x,y) = NE(x,y) + min([NM(x-1,y-1) NM(x-1,y)]);
            else
                NM(x,y) = NE(x,y) + min([NM(x-1,y-1) NM(x-1,y) NM(x-1,y+1)]);
            end
        end
    end
end
figure
imagesc(M),title("Minimum Energy Graph");
figure
imshow(RI),title("Resized Image");
[output] = RI;

