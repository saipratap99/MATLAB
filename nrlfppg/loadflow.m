% Program for Bus Power Injections, Line & Power flows (p.u)...
% Updated on Jan-6-2018, Praviraj PG
function [fb, tb, Pij, Qij] = loadflow(num,V,del,BMva)

Y = ybusppg(num);          % Calling Ybus program..
lined = linedatas(num);
busd = busdatas(num);
Vm = pol2rect(V,del);       % Converting polar to rectangular..
Del = 180/pi*del;           % Bus Voltage Angles in Degree...
fb = lined(:,1);            % From bus number...
tb = lined(:,2);            % To bus number...
b = lined(:,5);             % Ground Admittance, B/2...
a = lined(:,6);             % Tap setting value..
nl = length(fb);            % No. of Branches..
Pl = busd(:,7);             % PLi..
Ql = busd(:,8);             % QLi..

nb = length(Vm);            % Number of buses
Iij = zeros(nb,nb);
Sij = zeros(nb,nb);

% Bus Current Injections..
 I = Y*Vm;
 Im = abs(I);
 Ia = angle(I);
 
%Line Current Flows..
 for m = 1:nb
     for n = 1:nl
         if fb(n) == m
             p = tb(n);
             Iij(m,p) = -(Vm(m) - Vm(p)*a(n))*Y(m,p)/a(n)^2 + b(n)/a(n)^2*Vm(m);  % Y(m,n) = -y(m,n)..
%            Iij(m,p) = -(Vm(m) - Vm(p)*a(n))*Y(m,p)/a(n)^2;
             Iij(p,m) = -(Vm(p) - Vm(m)/a(n))*Y(p,m) + b(n)*Vm(p);
%            Iij(p,m) = -(Vm(p) - Vm(m)/a(n))*Y(p,m);
         elseif tb(n) == m
             p = fb(n);
             Iij(m,p) = -(Vm(m) - Vm(p)/a(n))*Y(p,m) + b(n)*Vm(m);
%            Iij(m,p) = -(Vm(m) - Vm(p)/a(n))*Y(p,m);
             Iij(p,m) = -(Vm(p) - Vm(m))*Y(m,p)/a(n)^2 + b(n)/a(n)^2*Vm(p);
%            Iij(p,m) = -(Vm(p) - Vm(m))*Y(m,p)/a(n)^2;
         end
     end
 end
 
% for m = 1:nl
%     p = fb(m); q = tb(m);
%     Iij(p,q) = -(Vm(p) - Vm(q))*Y(p,q); % Y(m,n) = -y(m,n)..
%     Iij(q,p) = -Iij(p,q);
% end
 
 Iijr = real(Iij);
 Iiji = imag(Iij);

 % Line Power Flows..
 for m = 1:nb
     for n = 1:nb
         if m ~= n
             Sij(m,n) = Vm(m)*conj(Iij(m,n))*BMva;
         end
     end
 end
 Pij = real(Sij);
 Qij = imag(Sij);
 
 % Line Losses..
 Lij = zeros(nl,1);
 for m = 1:nl
     p = fb(m); q = tb(m);
     Lij(m) = Sij(p,q) + Sij(q,p);
 end
 Lpij = real(Lij);
 Lqij = imag(Lij);
 
 % Bus Power Injections..
 Si = zeros(nb,1);
 for i = 1:nb
     for k = 1:nb
         Si(i) = Si(i) + conj(Vm(i))* Vm(k)*Y(i,k)*BMva;
     end
 end
 Pi = real(Si);
 Qi = -imag(Si);
 Pg = Pi+Pl;
 Qg = Qi+Ql;
 
disp('#########################################################################################');
disp('-----------------------------------------------------------------------------------------');
disp('                              Newton Raphson Loadflow Analysis ');
disp('-----------------------------------------------------------------------------------------');
disp('| Bus |    V   |  Angle  |     Injection      |     Generation     |          Load      |');
disp('| No  |   pu   |  Degree |    MW   |   MVar   |    MW   |  Mvar    |     MW     |  MVar | ');
for m = 1:nb
    disp('-----------------------------------------------------------------------------------------');
    fprintf('%3g', m); fprintf('  %8.4f', V(m)); fprintf('   %8.4f', Del(m));
    fprintf('  %8.2f', Pi(m)); fprintf('   %8.2f', Qi(m)); 
    fprintf('  %8.2f', Pg(m)); fprintf('   %8.2f', Qg(m)); 
    fprintf('  %8.2f', Pl(m)); fprintf('   %8.2f', Ql(m)); fprintf('\n');
end
disp('-----------------------------------------------------------------------------------------');
fprintf(' Total                  ');fprintf('  %8.3f', sum(Pi)); fprintf('   %8.3f', sum(Qi)); 
fprintf('  %8.3f', sum(Pi+Pl)); fprintf('   %8.3f', sum(Qi+Ql));
fprintf('  %8.3f', sum(Pl)); fprintf('   %8.3f', sum(Ql)); fprintf('\n');
disp('-----------------------------------------------------------------------------------------');
disp('#########################################################################################');

disp('-------------------------------------------------------------------------------------');
disp('                              Line Flow and Losses ');
disp('-------------------------------------------------------------------------------------');
disp('|From|To |    P    |    Q     | From| To |    P     |   Q     |      Line Loss      |');
disp('|Bus |Bus|   MW    |   MVar   | Bus | Bus|    MW    |  MVar   |     MW   |    MVar  |');
for m = 1:nl
    p = fb(m); q = tb(m);
    disp('-------------------------------------------------------------------------------------');
    fprintf('%4g', p); fprintf('%4g', q); fprintf('  %8.2f', Pij(p,q)); fprintf('   %8.2f', Qij(p,q)); 
    fprintf('   %4g', q); fprintf('%4g', p); fprintf('   %8.2f', Pij(q,p)); fprintf('   %8.2f', Qij(q,p));
    fprintf('  %8.2f', Lpij(m)); fprintf('   %8.2f', Lqij(m));
    fprintf('\n');
end
disp('-------------------------------------------------------------------------------------');
fprintf('   Total Loss                                                 ');
fprintf('  %8.3f', sum(Lpij)); fprintf('   %8.3f', sum(Lqij));  fprintf('\n');
disp('-------------------------------------------------------------------------------------');
disp('#####################################################################################');