function balance_triangle_distribution(triangles)

triangles = triangles(:,[1 3 2 4]);
n = size(triangles,1);
sparsity = [1:n]*100/n;

triangles(:,3) = triangles(:,3) + triangles(:,4);
triangles(:,2) = triangles(:,2) + triangles(:,3);
triangles(:,1) = triangles(:,1) + triangles(:,2);

colours=[160 32 240; 0 100 0; 218 165 32;30 144 255;
    255 20 147; 148 0 211;  205 92 92; 238 213 183]/255;

plot(sparsity, triangles(:,4),'Color',colours(5,:),'LineWidth',2); hold on;
plot(sparsity, triangles(:,3),'Color',colours(4,:),'LineWidth',2); hold on;
plot(sparsity, triangles(:,2),'Color',colours(3,:),'LineWidth',2); hold on;
plot(sparsity, triangles(:,1),'Color',colours(2,:),'LineWidth',2); hold on;

set(gca,'xTick',0:20:100);
set(gca,'xTickLabel',0:0.2:1.0);

set(gca,'yTick',0:0.2:1);
set(gca,'yTickLabel',0:0.2:1);

xlabel('Fraction of remaining edges ','FontSize',20);
ylabel('Fraction of triangles ','FontSize',20);

set(gca,'FontSize',17);
set(gca,'LineWidth',3);
xlim([0 100]);
ylim([0 1]);