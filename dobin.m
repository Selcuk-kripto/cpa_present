% Onluk tabandaki K say�s�n� k bite d�n��t�r�r
function Y=dobin(K,k)

A=dec2bin(K,k);
X=find(A=='1');
[m,n]=size(X);
Y(1:k)=0;
if n > 0
   for j=1:n
      Y(X(j))=1;
   end
else 
   Y(1:k)=0;
end