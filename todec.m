% Bit dizisi L'yi onluk taban degerine dönüstürür
function M=todec(L)
N=0;
i=1;
for n=length(L)-1:-1:0
   N=N+L(i)*(2^n);
   i=i+1;
end
M=N;

