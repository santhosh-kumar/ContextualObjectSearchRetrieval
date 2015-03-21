function [acc] = CrossValidateKNN_RFD(y, X,  k, knn_size,num)
%  function [acc,A, pred] = CrossValidateKNN(y, X, tCL, k, knn_size),M);
% [acc, pred] = CrossValidateKNN(y, X, tCL, k, knn_size);
%
% Cross-validation for evaluating the k-nearest neighbor classifier with
% a learned metric.  Performs k-fold cross validation, training on the
% training fold and evaluating on the test fold
%
% y: (n x 1) true labels
%
% X: (n x m) data matrix
%
% tCL: Metric learning algorithm that takes in true labels as first
% argument, and data as a second
%
% k: Number of cross-validated folds
%
% knn_size: size of nearest neighbor window
%
% Returns
% acc: cross-validated accuracy
[n,m] = size(X);
if (n ~= length(y)),
    disp('ERROR: num rows of X must equal length of y');
    return;
end

rp = randperm(n);
y = y(rp);
X = X(rp, :);

errs = zeros(k,1);
fprintf('\n%d folds cross validation\n',k);
for i=1:k
    test_start = ceil(n/k * (i-1)+ 0.5) ;
    test_end = ceil(n/k * i);

    yt = [];
    Xt = zeros(0, m);
    if (i > 1);
        yt = y(1:test_start-1);
        Xt = X(1:test_start-1,:);
    end
    if (i < k),
        yt = [yt; y(test_end+1:length(y))];
        Xt = [Xt; X(test_end+1:length(y), :)];
    end

    nt = length(yt);
    yt = yt(1:nt);
    Xt = Xt(1:nt, :);

    tempn = length(unique(yt));
    C = [];
    [C] = generate_constraints_by_number_C1(Xt', yt', num*tempn);
    
    
    Xt1 = abs(Xt(C(:,1),:)-Xt(C(:,2),:));
    Xt11 = (Xt(C(:,1),:)+Xt(C(:,2),:))/2;
    Xt11 = Xt11.*repmat((sum(Xt1,2)>0),1,size(Xt1,2));

    Yt1 = C(:,3);
    X_trn = [];
    X_trn = [Xt11 Xt1];
    Y_trn = Yt1;
    errrate = [];
    for ntree = 4:4
        extra_options.replace = 1;
        extra_options.nodesize = 1;
        model = classRF_train(X_trn,Y_trn, ntree*200,0,extra_options);
        XT = X(test_start:test_end, :);
        yT = y(test_start:test_end);
        

        pred = zeros(size(XT,1),1);
        X_tst = [];
        for j = 1:size(XT,1)
            X_tst = abs(repmat(XT(j,:),size(Xt,1),1)-Xt);
            X_tst1 = (repmat(XT(j,:),size(Xt,1),1)+Xt)/2;
            X_tst1 = X_tst1.*repmat((sum(X_tst,2)>0),1,size(X_tst,2));
            X_tst = [X_tst1 X_tst];
            
            dists = classRF_predict_dis(X_tst,model);

            counts = [];
            for kk = 1:knn_size
                [v,ind] = min(dists);
                if yt(ind) > length(counts)
                    counts(yt(ind)) = 1;
                else
                    counts(yt(ind)) = counts(yt(ind)) + 1;
                end
                dists(ind)=inf;
                %ind
            end
            [v,pred(j)] = max(counts);
        end
        fprintf('\nThe %dth fold: %d trees: accurace %f \n', i,200*ntree, (1-length(find(pred~=yT))/length(pred))*100);
        errrate = [errrate; length(find(pred~=yT))/length(pred)];
    end
    errs(i) = mean(errrate(end));
end
acc = (1-mean(errs))*100;
fprintf('\nThe average accurace is: %f \n',acc);

