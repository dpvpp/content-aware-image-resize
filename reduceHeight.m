function [output] = reduceHeight(im,numPixels)
figure
imshow(im),title("Image");
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
M(:,1) = E(:,1);
for y = 2:n
    for x = 1:m
        if x == 1
            M(x,y) = E(x,y) + min([M(x,y-1) M(x+1,y-1)]);
        elseif x == m
            M(x,y) = E(x,y) + min([M(x-1,y-1) M(x,y-1)]);
        else
            M(x,y) = E(x,y) + min([M(x-1,y-1) M(x,y-1) M(x+1,y-1)]);
        end
    end
end

NM = M;
RI = im;
NE = E;
nm = m;
for j = 1:numPixels
    om = nm;
    nm = nm-1;
    E2 = NE;
    M2 = NM;
    im2 = RI;
    [mn,i] = min(M2(:,n));    
    disp(mn)
    S = zeros(n);
    S(n) = i;
    RI = uint8(zeros(nm,n,3));
    NE = zeros(nm,n);
    NM = zeros(nm,n);
    for y = n:-1:2
        if S(y) == 1
            [mn, i] = min([M2(S(y),y-1) M2(S(y)+1,y-1)]);
            S(y-1) = S(y)-1+i;
            RI(:,y,:) = im2(2:om,y,:);
            NE(:,y) = E2(2:om,y);
        elseif S(y) == om
            [mn, i] = min([M2(S(y)-1,y-1) M2(S(y),y-1)]);
            S(y-1) = S(y)-2+i;
            RI(:,y,:) = im2(1:nm,y,:);
            NE(:,y) = E2(1:nm,y);
        else
            [mn, i] = min([M2(S(y)-1,y-1) M2(S(y),y-1) M2(S(y)+1,y-1)]);
            S(y-1) = S(y)-2+i;
            RI(:,y,:) = im2(1:om ~= S(y),y,:);
            NE(:,y) = E2(1:om ~= S(y),y);
        end
    end
    RI(:,1,:) = im2(1:om ~= S(1),1,:);
    NE(:,1) = E2(1:om ~= S(1),1);
    NM(:,1) = NE(:,1);
    for y = 2:n
        for x = 1:nm
            if x == 1
                NM(x,y) = NE(x,y) + min([NM(x,y-1) NM(x+1,y-1)]);
            elseif x == m
                NM(x,y) = NE(x,y) + min([NM(x-1,y-1) NM(x,y-1)]);
            else
                NM(x,y) = NE(x,y) + min([NM(x-1,y-1) NM(x,y-1) M(x+1,y-1)]);
            end
        end
    end
end
figure
imagesc(M),title("Minimum Energy Graph");
figure
imshow(RI),title("Resized Image");
[output] = RI;
