% Implementation of Berger's background subtraction
%
% Analyst, 2009, 134, 1198 - 1202, DOI: 10.1039/b821856k
%[R,c_fun] = berger(S,X,berger_order)
% S = Original Spectrum
% X = Interferent Spectrum
% O = Order

function [R,c_fun] = berger(S,X,berger_order)
  warning('off','all'); 
  i=1;
  B(1,:) = S;
  K=[X; ones(1,size(X,2))];
  [C,resnorm,res] = nnfit(S,K);
  c_fun = 0.6*C(1);
  eps=800;

while(true) 
   options = optimset('Display','off');%%optimset('MaxIter',25,'MaxFunEvals',25,'Display','off','TolFun',1e-8,'TolX',1e-8);    
   C_int(i) = fminsearch(@(c_fun) myfun(c_fun, B(i,:), X, berger_order),[c_fun],options); 
   
   F(i,:) = B(i,:) - C_int(i)*X;
   F_res(i,:) = lieberfit(F(i,:),berger_order,50);
%  F_res(i,:) = minmaxfit(F(i,:),4,50);
   P(i,:) = F(i,:) - F_res(i,:);
      
   B(i+1,:) = C_int(i)*X + P(i,:);
   B(i+1,:) = min(B(i,:),B(i+1,:));
    
    if(norm(B(i+1,:)-B(i,:),2)<eps)
      break;
    end
    
    c_fun = C_int(i);
    i=i+1;

end
   
  R = S - (C_int(i)*X + P(i,:));
%   R(:,1)=0;
%   R(:,end)=0;

  end

% Function
function merit=myfun(C_int, B,X,berger_order) 

   F = B - C_int*X;
%    fluo = B - X*C_int-lieberfit(F,berger_order,50);
%    K = [fluo; X; ones(1,size(X,2))];
% 
%    
%    [C_ols,merit,F_res] = nnfit(B,K);
   F_res = lieberfit(F,berger_order,50);
      
%    max_F_res = max(F_res);
%    array = [];
%    
%    for i=1:609
%       
%        if(F_res(i)<=0.7*max_F_res)
%            array = [array;i];
%        end
%    end
%    
merit = norm(F_res,2);
end
  
  
% Lieber fit
% S is a matrix of input spectra with each observation in the rows
% order is the order of polynomial fit
% tot_iter is the number of iterations for the code to fit the baseline
function outspectrum = lieberfit(S, order, tot_iter)

warning ('off','all')

num_samp = size(S, 1); 

pix_size = size(S, 2); 

polyspec_iter = []; 
outspectrum = []; 

for j = 1:num_samp; 

    polyspec_iter = S(j,1:pix_size); 
    
  for i = 1:tot_iter;
    
    p_order=polyfit([1:pix_size],polyspec_iter,order);
    polyspec_order=polyval(p_order,[1:pix_size]);
    polyspec_iter = min(polyspec_order, polyspec_iter);
         
  end
  
  outspectrum(j,:) = S(j,:) - polyspec_iter(1,:); 
  
end
end


function outspectrum = minmaxfit(S, order, tot_iter)

warning ('off','all')

num_samp = size(S, 1); 

pix_size = size(S, 2); 

polyspec_iter = []; 
outspectrum = []; 

for j = 1:num_samp; 

    polyspec_iter = S(j,1:pix_size); 
    polyspec_iter_plus_one = S(j,1:pix_size);
    
  for i = 1:tot_iter;
    
    p_order=polyfit([1:pix_size],polyspec_iter,order);
    polyspec_order=polyval(p_order,[1:pix_size]);
    polyspec_iter = min(polyspec_order, polyspec_iter);
    
    p_order_plus_one=polyfit([1:pix_size],polyspec_iter_plus_one,order+1);
    polyspec_order_plus_one=polyval(p_order_plus_one,[1:pix_size]);
    polyspec_iter_plus_one = min(polyspec_order_plus_one, polyspec_iter_plus_one);
        
  end
  
  polyspec_final = max(polyspec_iter, polyspec_iter_plus_one); 
  outspectrum(j,:) = S(j,:) - polyspec_final(1,:); 
  
end
end