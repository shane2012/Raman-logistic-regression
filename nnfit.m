function [C,resnorm,res] = nnfit(S,P)
%function C = nnfit(S, P)
%
%Uses improved algorithm for non-negative least-squares fitting.
%Based on MATLAB's lsqnonneg command.
%C refers to "concentration", P is the pure spectrum, and S is the mixture spectrum.
%
itnum=size(S,1);

for i=1:itnum,
   [CC(:,i),resnorm(:,i),res(:,i)]=lsqnonneg(P',S(i,:)');
end;


C=CC';
