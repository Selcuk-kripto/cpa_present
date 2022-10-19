clear all
 
%pLayer 
PR=[0 16 32 48 1 17 33 49 2 18 34 50 3 19 35 51 4 20 36 52 5 21 37 53 6 22 38 54 7 23 39 55 8 24 40 56 9 25 41 57 10 26 42 58 11 27 43 59 12 28 44 60 13 29 45 61 14 30 46 62 15 31 47 63] + 1; 

%invpLayer
PI=[0 4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 1 5 9 13 17 21 25 29 33 37 41 45 49 53 57 61 2 6 10 14 18 22 26 30 34 38 42 46 50 54 58 62 3 7 11 15 19 23 27 31 35 39 43 47 51 55 59 63] +1; % Inverse
 
% sBox
Shex='C56B90AD3EF84712';
for i=1:16
    t=hex2dec(Shex(i));
    S(i)=t;
    Sb(i,:)=dobin(t,4);% S-kutusunun ikili versiyonu
    Sinv(t+1)=i-1;% invsBox
end
 
% Gizli anahtar
Kth='00010203040506070809';
 
Kt=[];
for i=1:20
    Kt=[Kt dobin(hex2dec(Kth(i)),4)];
end  
 
K=Kt;
 
% Guc olcum sayisi
TN=5000;
 
% Tahmin entropisini (eklenen) her 100 olcumde yeniler
stp=100;
 
%Gurultunun standart sapmasi
std=18;
 
% Orneklem sayisi (Simule edilen guc olcumu uzunlugu)
Ts=1000;
 

% Tur anahtarlarini uretir
R(1,:)=K(1:80);        
for i=2:32
    K=[K(62:80) K(1:61)];
    t=todec(K(1:4));% 4 biti onluk tabana cevirir
    K(1:4)=Sb(t+1,:);
    rc=dobin(i-1,5);  
    K(61:65)=xor(K(61:65),rc);
    R(i,:)=K(1:80); 
end
 
Kc=R(32,PR(33:36));
 
% Tahmin edilmesi beklenen gercek anahtar
kcd=todec(Kc);
 
% Aday anahtarlar
for i=1:16
    Ka(i,:)=dobin(i-1,4);
end
 
% Tahmin matrisi
H(1:TN,1:16)=0;
 
% Tahmin matrisini hesaplar 
for I=1:TN
    C=round(rand([1 64])); % Rastgele uretilen acik metin   
    C=xor(C,R(1,1:64));
    for i=2:31% PRESENT'in ilk 30 turu
        for j=1:16 
            t=todec(C(4*(j-1)+1:4*j));
            C(4*(j-1)+1:4*j)=Sb(t+1,:);
        end
        C(PR)=C; 
        C=xor(C,R(i,1:64));   
    end  
    % Son tur
    tx=C; % Son turun girisi
    for j=1:16 
        t=todec(C(4*(j-1)+1:4*j)); 
        C(4*(j-1)+1:4*j)=Sb(t+1,:);
    end
    C(PR)=C; 
    C=xor(C,R(32,1:64));   
    ty=C; % Son turun cikisi
 
    % Simule edilen güc olcumu
    TR(I,:)=sum(xor(tx,ty))+std*randn([1 Ts]);          
   
    So=C(PR(33:36));
    Soc=C(33:36);
        
    for i=1:16
        to=xor(Ka(i,:),So);
        t=Sinv(todec(to)+1);
        H(I,i)=sum(xor(dobin(t,4),Soc));
    end        
    if rem(I,1000)==0
        [1 I]
    end
end
 
rx(1:16,1:(TN-stp)/stp+1)=0;
cnt=0;
CFa=[];
    
% Her 100 olcum icin tahmin entropisini hesaplar
for pn=stp:stp:TN
    if rem(pn,1000)==0
        [2 pn]
    end
    for i=1:16
        h=H(1:pn,i);
        mh=sum(h)/pn;
        h=h-mh;
        hs=h'*h;
        for j=1:Ts
            t=TR(1:pn,j);
            mt=sum(t)/pn;
            t=t-mt;        
            ts=t'*t;
            CF(i,j)=(h'*t)/sqrt(hs*ts); % Korelasyon matrisi
        end
        CFm(i)=max(abs((CF(i,:))));
    end    
    CFa=[CFa CFm'];
    [a ix]=sort(CFm,'descend');
    cnt=cnt+1;
    rx(ix,cnt)=(1:16)'-1;
end  
plot(rx(kcd+1,:));
xlabel('Olcum Sayisi (10^2)')
ylabel('Tahmin entropisi')                      
 

   

