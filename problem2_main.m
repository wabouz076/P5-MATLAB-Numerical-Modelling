% Problem 2 
clc; clear; close all;

% P2 constant 
P2_const = 13;

% Load ranges. P1 up to 30kN, P3 up to 51kN 
P1_range = linspace(0, 30, 100);
P3_range = linspace(0, 51, 100);

% Preallocate output matrices (one for max tension, one for max compression)
MaxTension = zeros(100, 100);
MaxCompression = zeros(100, 100);

% Nested loop over every (P1, P3) combination
for i = 1:100   
    for j = 1:100   
    P1 = P1_range(j);
    P3 = P3_range(i);

     results = truss_solver(P1, P2_const, P3);
     membersforces = results(4:14);  % F1 to F11 sit at indices 4-14

     MaxTension(i, j) = max([0; membersforces]);
     MaxCompression(i, j) = abs(min([0; membersforces]));
    end
end

% Calculate FoS for every point 
FoS_T = 40 ./ MaxTension;
FoS_C = 60 ./ MaxCompression;

% Find the absolute lowest FoS across all 10,000 permutations
absolute_min_fos = min(min(FoS_T(:)), min(FoS_C(:)));

% Count how many combinations breached the failure limits
failed_count = sum((MaxTension(:) > 40) | (MaxCompression(:) > 60));
total_count = numel(MaxTension); % Will be 10,000

% Print
fprintf('Min FoS: %.3f\n', absolute_min_fos);
fprintf('%d of %d combinations failed (FoS < 1)\n', failed_count, total_count);


% constructing the meshgrid 
[X, Y] = meshgrid(P1_range, P3_range);

figure('Name', 'Design Space Analysis', 'Position', [100, 100, 1050, 450], 'Color', 'w');
sgtitle('Parametric Load Analysis', 'FontWeight', 'bold');

% Max Tension visulisation plot
ax1 = subplot(1, 2, 1);
contourf(X, Y, MaxTension, 20, 'LineStyle', 'none'); hold on;
cb1 = colorbar;
ylabel(cb1, 'Force Magnitude (kN)', 'FontWeight', 'bold');

% Red contour line marks where the most loaded member hits exactly FoS=2
[CT, HT] = contour(X, Y, MaxTension, [20 20], 'k', 'LineWidth', 2.5);
clabel(CT, HT, 'FontSize', 11, 'Color', 'r', 'FontWeight', 'bold', 'BackgroundColor', 'w');

title('Max Tension (kN) FoS=2 ');
xlabel('P1 Load (kN)');
ylabel('P3 Load (kN)');
set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'Box', 'on', 'Layer', 'top');
colormap(ax1, 'autumn'); 

ax2 = subplot(1, 2, 2);
contourf(X, Y, MaxCompression, 20, 'LineStyle', 'none'); hold on;
cb2 = colorbar;
ylabel(cb2, 'Force Magnitude (kN)', 'FontWeight', 'bold');

% Compression limit is 60kN therefore FoS=2 boundary sits at 30kN
[cC, hC] = contour(X, Y, MaxCompression, [30 30], 'k', 'LineWidth', 2.5);
clabel(cC, hC, 'FontSize', 11, 'Color', 'r', 'FontWeight', 'bold', 'BackgroundColor', 'w');

title('Max Compression (kN) FoS=2 ');
xlabel('P1 Load (kN)');
ylabel('P3 Load (kN)');
set(gca, 'FontSize', 11, 'LineWidth', 1.2, 'Box', 'on', 'Layer', 'top');
colormap(ax2, 'autumn');

% Loading interactive slider UI with P2 locked.
launch_interactive_truss(P2_const);


function launch_interactive_truss(P2const)
    % Main figure window
    fig = uifigure('Name', 'Interactive Truss', 'color' , ' white' , 'Position', [150, 50, 900, 750]);

    % Status bar at the top updates every time a slider moves
    label_status = uilabel(fig, 'Position', [50, 715, 800, 22], 'FontSize', 13, 'FontWeight', 'bold');

    % Truss drawing with colour coded members
    AXtruss = uiaxes(fig, 'Position', [50, 360, 800, 340]);
    axis(AXtruss, 'equal');
    grid(AXtruss, 'on');
    title(AXtruss, 'Live Truss Load Distribution (Blue=Tension, Red=Compression)');
    xlabel(AXtruss, 'X (m)');
    ylabel(AXtruss, 'Y (m)');

    % Bar chart of individual member forces
    AXbar = uiaxes(fig, 'Position', [50, 100, 800, 220]);
    grid(AXbar, 'on');
    title(AXbar, 'Live Member Forces (kN)');
    xlabel(AXbar, 'Member ID');
    ylabel(AXbar, 'Force (kN)');

    % P1 slider left side
    uilabel(fig, 'Position', [150, 60, 100, 22], 'Text', 'P1 Load (kN):');
    sliderp1 = uislider(fig, 'Position', [150, 50, 250, 3], 'Limits', [0, 30], 'Value', 10);

    % P3 slider right side
    uilabel(fig, 'Position', [500, 60, 100, 22], 'Text', 'P3 Load (kN):');
    sliderp3 = uislider(fig, 'Position', [500, 50, 250, 3], 'Limits', [0, 51], 'Value', 17);

    % slider callbacks both call the same update function
    sliderp1.ValueChangingFcn = @(sld, event) UpdateTrussPlot(AXtruss, AXbar, event.Value, sliderp3.Value, P2const, label_status);
    sliderp3.ValueChangingFcn = @(sld, event) UpdateTrussPlot(AXtruss, AXbar, sliderp1.Value, event.Value, P2const, label_status);

    % Draw initial state at default P1=10, P3=17 
    UpdateTrussPlot(AXtruss, AXbar, sliderp1.Value, sliderp3.Value, P2const, label_status);
end

function UpdateTrussPlot(axtruss, axbar, P1, P3, P2const, label_status)

    % Solve the truss for the current slider values
    results = truss_solver(P1, P2const, P3);
    f = results(4:14);  % member forces F1-F11

    % Node coordinates and member connectivity to match the truss geometry
    nodes   = [0 0; 3 0; 6 0; 9 0; 1.5 3; 4.5 3; 7.5 3];
    members = [1 2; 2 3; 3 4; 5 6; 6 7; 1 5; 5 2; 2 6; 6 3; 3 7; 7 4];

    % Redesigning the truss diagram 
    cla(axtruss); hold(axtruss, 'on');

    % update line thickness against the most loaded member
    MaxF = max(abs(f));
    if MaxF == 0, MaxF = 1; end 

    for k = 1:size(members, 1)
        pt1 = nodes(members(k, 1), :);
        pt2 = nodes(members(k, 2), :);

        
        if f(k) < 0
            line_color = 'r';
            fos = 60 / abs(f(k));   
        else
            line_color = 'b';
            if f(k) == 0
                fos = inf;          
            else
                fos = 40 / f(k);  % tension limit = 40kN
            end
        end

        % Thicker line means higher force allowing it easier to spot the critical members
        thickness = max(1, 1 + 5 * (abs(f(k)) / MaxF));
        plot(axtruss, [pt1(1) pt2(1)], [pt1(2) pt2(2)], line_color, 'LineWidth', thickness);

        % make sure labels don't sit on top of the member
        mid_x = mean([pt1(1), pt2(1)]);
        mid_y = mean([pt1(2), pt2(2)]);
        dx = pt2(1) - pt1(1);
        dy = pt2(2) - pt1(2);
        len = sqrt(dx^2 + dy^2);
        nx = -dy / len;
        ny =  dx / len;

        % Highlight in red if FoS drops below 2 (key safety check)
        if fos < 2
            txt_colour = 'r'; 
            weight = 'bold';
        else
            txt_colour = 'k'; 
            weight = 'normal';
        end

        % member ID and force value above the member line
        text(axtruss, mid_x + nx*0.2, mid_y + ny*0.2, sprintf('M%d: %.1fkN', k, f(k)),'FontSize', 8, 'HorizontalAlignment', 'center','Color', txt_colour, 'FontWeight', weight);

        % FoS label below the member line
        if isinf(fos)
            fos_stress = 'FoS: --';   
        else
            fos_stress = sprintf('FoS: %.1f', fos);
        end
        text(axtruss, mid_x - nx*0.2, mid_y - ny*0.2, fos_stress,'FontSize', 8, 'HorizontalAlignment', 'center', 'Color', txt_colour, 'FontWeight', weight);
    end

    % Draw nodes on top so they don't get buried under member lines
    plot(axtruss, nodes(:,1), nodes(:,2), 'ko', 'MarkerFaceColor', 'w', 'MarkerSize', 6);

    % Redraw the bar chart
    cla(axbar); hold(axbar, 'on');
    bar_obj = bar(axbar, 1:11, f, 'FaceColor', 'flat');

    % Colour each bar individually (red for c, blue for t)
    for c = 1:11
        if f(c) < 0
            bar_obj.CData(c, :) = [1 0 0];
        else
            bar_obj.CData(c, :) = [0 0 1];
        end
    end

    % Dashed limit lines so you can instantly see if anything is over capacity
    yline(axbar,  40, 'r--', 'Tension Limit (40kN)',     'LabelHorizontalAlignment', 'left', 'FontWeight', 'bold');
    yline(axbar, -60, 'r--', 'Compression Limit (60kN)', 'LabelHorizontalAlignment', 'left', 'FontWeight', 'bold');

    ylim(axbar, [-80 60]);
    xticks(axbar, 1:11);
    xticklabels(axbar, {'M1','M2','M3','M4','M5','M6','M7','M8','M9','M10','M11'});

    % Update the top status bar with the current load state and worst-case forces
    label_status.Text = sprintf( 'Live State | P1: %.1fkN | P3: %.1fkN | Max Tension: %.1fkN | Max Comp: %.1fkN', P1, P3, max([0; f]), abs(min([0; f])));
end
