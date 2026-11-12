% A factory consists of two consecutive desks. The service times of the desks are exponentially distributed,
% with distribution parameter values given by 1.2 and 1.4. There is no delay in the input to the system.
% Simulate the average output rate of the system with
% (i) a time-marching method, with a "suitable" time-stepping constant selected;
% (ii) with the event-based method.
% Compare the results for accuracy and CPU time.
%% Time-marching method
clc
close all
clearvars

Nsim = 10000;
Ntime = 5*Nsim;
dt = 1/60; % on seconds
mu1 = 1.2;
mu2 = 1.4;
td1 = exprnd(mu1,Nsim,1); % service_times desk 1
td2 = exprnd(mu2,Nsim,1); % service_times desk 2
% desk1 departure times = arrival to desk 2
d2_arr = cumsum(td1);
% rows customers; columns: service1time waiting service2time
services_rep = zeros(Nsim,4);
services_rep(:,1) = td1; % we can set desk1 times already
services_rep(:,3) = td2;
% time based
t = 0;
d2_rem = 0; % remaining job time
queue2 = 0; % length of queue
idx_arr = 1;% idx arrivals
idx_depart = 1; % idx departing
tStart = cputime; % start cpu clock
tic; % wall time
while idx_depart <= Nsim
    % update the time
    t = t + dt;
    % arrive to desk 1
    while (idx_arr <= Nsim) && (t >= d2_arr(idx_arr))
        queue2 = queue2 + 1;
        idx_arr = idx_arr + 1;
    end
    % complete service at desk 2
    if d2_rem > 0
        % reduce the remaining time
        d2_rem = d2_rem - dt;
        % check waiting
        if d2_rem <= 0
            d2_rem = services_rep(idx_depart,3);
            % wait = current t - arrival_t - d2 service time
            wait_time = t - d2_arr(idx_depart) - services_rep(idx_depart,3);
            % note the wait time per customer
            services_rep(idx_depart,2) = wait_time;
            % update the leaving customer
            idx_depart = idx_depart + 1;
        end
    end
    % now if desk2 is free, start service
    if (d2_rem <= 0) && (queue2 > 0) && (idx_depart <= Nsim)
        d2_rem = services_rep(idx_depart,3);
        % reduce queue
        queue2 = queue2 - 1;
    end
end
tEnd = cputime - tStart;
wallT_end = toc;
services_rep(:,4) = services_rep(:,1) + services_rep(:,2) + services_rep(:,3);
output_minu = Nsim/t;% how many customers out / total time served (minutes)
output_hour = output_minu*60; % customers per hour
mean_twait = mean(services_rep(:,2)); % mean waiting time
theoretical_max = 60/1.2; % bottleneck at desk 1
% results
disp(['Mean wait time: ', num2str(mean_twait,3)])
disp(['Total time: ', num2str(t,3)])
disp(['Output rate (per min): ', num2str(output_minu,3)])
disp(['Output rate (per hour): ', num2str(output_hour,3)])
disp(['Theoretical maximum: ', num2str(theoretical_max,3)])
disp(['Accuracy: ',num2str(100*(1 - abs(output_hour-theoretical_max)/theoretical_max),3)])
disp(['CPU time: ',num2str(tEnd,8)])
disp(['Wall time: ',num2str(wallT_end,3)])
%% Event-based method
clc
close all
clearvars

Nsim = 10000;
mu1 = 1.2;
mu2 = 1.4;
td1 = exprnd(mu1,Nsim,1); % service_times desk 1
td2 = exprnd(mu2,Nsim,1); % service_times desk 2
% rows: customers, 
% columns: service_time1, waiting, service_time2, total time
services_rep = zeros(Nsim,4);
services_rep(:,1) = td1; % we can set desk1 times already
services_rep(:,3) = td2; % we can set desk2 times already
d2_arr = cumsum(td1);
% event-based
desk2_free = 0;
arrival_to_desk2 = 0;
% go through the simulations
tStart = cputime; % start cpu clock
tic; % wall time
% store the times
times = zeros(Nsim,2);
% iterate Nsim times
for ns = 1:Nsim
    % desk1 finishes a job, desk2 starts
    % arrival_to_desk2 = arrival_to_desk2 + services_rep(ns,1);
    % waiting time to be served by desk 2
    services_rep(ns,2) = max(0,desk2_free - d2_arr(ns));
    % desk 2 finishes
    desk2_free = max(desk2_free, arrival_to_desk2) + services_rep(ns,3);
end
tEnd = cputime - tStart;
wallT_end = toc;
% end wall time
services_rep(:,4) = services_rep(:,1) + services_rep(:,2) + services_rep(:,3);
% what is the final time
total_time = desk2_free;
output_minu = Nsim/total_time;% how many customers out / total time served (minutes)
output_hour = output_minu*60; % 7.7240 customers per hour
mean_twait = mean(services_rep(:,2)); % mean waiting time
output_rate = Nsim / total_time;
output_per_hour = output_rate * 60;
theoretical_max = 60/1.2; % bottleneck at desk 1
% results
disp(['Mean wait time: ', num2str(mean_twait,3)])
disp(['Total time: ', num2str(total_time,3)])
disp(['Output rate (per min): ', num2str(output_minu,3)])
disp(['Output rate (per hour): ', num2str(output_hour,3)])
disp(['Theoretical maximum: ', num2str(theoretical_max,3)])
disp(['Accuracy: ',num2str(100*(1 - abs(output_hour-theoretical_max)/theoretical_max),3)])
disp(['CPU time: ',num2str(tEnd,8)])
disp(['Wall time: ',num2str(wallT_end,3)])
