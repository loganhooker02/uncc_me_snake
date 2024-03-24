%Use in same folder as video file, and load tagPosXXX matrices from
%vectorize_tagData results into active workspace
process_tagDatax('feb11trial1.mp4', tagPosX, tagPosY, tagYaw)
function process_tagDatax(videoFile, tagPosX, tagPosY, tagYaw)
    close all
    invalid_indices = (tagPosX == 0 | tagPosY == 0 | isnan(tagPosX) | isnan(tagPosY) | tagYaw == 0 | isnan(tagYaw));
    
    video = VideoReader(videoFile);
    
    x_data_filtered = tagPosX;
    y_data_filtered = tagPosY;
    yaw_data_filtered = tagYaw;
    x_data_filtered(invalid_indices) = NaN;
    y_data_filtered(invalid_indices) = NaN;
    yaw_data_filtered(invalid_indices) = NaN;
    
    num_tags = 3; % Number of tags
    num_frames = size(tagPosX, 1); % Number of frames
    
    framerate = video.FrameRate;
    seconds = (1:num_frames)/framerate;

    %Normalize data based on initial frame of middle link
    x_data_normalized = x_data_filtered - x_data_filtered(1,2);
    y_data_normalized = y_data_filtered - y_data_filtered(1,2);
    yaw_data_normalized = yaw_data_filtered - yaw_data_filtered(1,2);
    yaw_data_degrees = rad2deg(yaw_data_normalized);


    %Calculate major axis velocities
    dx = diff(tagPosX);
    dy = diff(tagPosY);
    temp = diff(seconds);
    dt = temp(1,1);
    vx = dx ./ dt;
    vy = dy ./ dt;
    [s1, s2] = size(vx);
    vx = zeros(s1, s2);
    vy = zeros(s1, s2);
    for tag = 1:num_tags
        vx(:, tag) = dx(:, tag) / dt;
        vy(:, tag) = dy(:, tag) / dt;
    end
    truev = sqrt(vx.^2 + vy.^2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plotting x and y data for each tag separately over time
    figure;
    for tag = 1:size(x_data_filtered, 2)
        subplot(ceil(sqrt(num_tags)), ceil(sqrt(num_tags)), tag); % Create subplots
        plot(seconds, x_data_filtered(:, tag), 'r', 'LineWidth', 1.5);
        hold on;
        plot(seconds, y_data_filtered(:, tag), 'b', 'LineWidth', 1.5);
        hold off;
        title(['Tag ', num2str(tag)]);
        xlabel('Seconds');
        ylabel('Coordinate');
        legend('X Coordinate', 'Y Coordinate');
    end
    
    % Plotting x and y data for each tag overlapped over time
    figure;
    hold on;
    for tag = 1:size(x_data_filtered, 2)
        plot(seconds, x_data_normalized(:, tag), 'LineWidth', 1.5);
        plot(seconds, y_data_normalized(:, tag), 'LineWidth', 1.5);
    end
    hold off;
    title('X and Y Coordinates of Tags Over Time');
    xlabel('Seconds');
    ylabel('Coordinate');
    legend('Tag 1 X', 'Tag 1 Y', 'Tag 2 X', 'Tag 2 Y', 'Tag 3 X', 'Tag 3 Y');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure;
    for tag = 1:size(x_data_filtered, 2)
        subplot(ceil(sqrt(num_tags)), ceil(sqrt(num_tags)), tag); % Create subplots
        plot(seconds(1:end-1), dx(:, tag), 'r', 'LineWidth', 1.5);
        hold on;
        plot(seconds(1:end-1), dy(:, tag), 'b', 'LineWidth', 1.5);
        hold off;
        title(['Tag ', num2str(tag)]);
        xlabel('Seconds');
        ylabel('Velocity');
        legend('X Coordinate', 'Y Coordinate');
    end
    
    % Plotting x and y data for each tag overlapped over time
    figure;
    hold on;
    for tag = 1:size(x_data_filtered, 2)
        plot(seconds(1:end-1), dx(:, tag), 'LineWidth', 1.5);
        plot(seconds(1:end-1), dy(:, tag), 'LineWidth', 1.5);
    end
    hold off;
    title('Velocity of X and Y of Tags Over Time');
    xlabel('Seconds');
    ylabel('Coordinate');
    legend('Tag 1 X', 'Tag 1 Y', 'Tag 2 X', 'Tag 2 Y', 'Tag 3 X', 'Tag 3 Y');

    figure;
    for tag = 1:size(x_data_filtered, 2)
        subplot(ceil(sqrt(num_tags)), ceil(sqrt(num_tags)), tag); % Create subplots
        plot(seconds(1:end-1), truev(:, tag), 'r', 'LineWidth', 1.5);
        title(['True Velocity of Tag ', num2str(tag)]);
        xlabel('Seconds');
        ylabel('True Velocity');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plotting yaw data for each tag separately   
    figure;
    for tag = 1:size(x_data_filtered, 2)
        subplot(ceil(sqrt(num_tags)), ceil(sqrt(num_tags)), tag); % Create subplots
        plot(seconds, yaw_data_degrees(:, tag), 'r', 'LineWidth', 1.5);
        title(['Yaw of Tag ', num2str(tag)]);
        xlabel('Seconds');
        ylabel('Angle Relative to Start');
    end
    
    % Plotting yaw data for each tag overlapped over time
    figure;
    hold on;
    for tag = 1:size(x_data_filtered, 2)
        plot(seconds, yaw_data_degrees(:, tag), 'LineWidth', 1.5);
    end
    hold off;
    title('Yaw of Tags Over Time');
    xlabel('Seconds');
    ylabel('Angle Relative to Start');
    legend('Tag 1 Yaw', 'Tag 2 Yaw', 'Tag 3 Yaw');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plotting x vs y data for each tag separately
    figure;
    hold on;
    for tag = 1:num_tags
        subplot(ceil(sqrt(num_tags)), ceil(sqrt(num_tags)), tag); % Create subplots
        scatter(x_data_normalized(:, tag), y_data_normalized(:, tag), '.');
        title(['Tag ', num2str(tag)]);
        xlabel('X Coordinate');
        ylabel('Y Coordinate');
    end
    hold off;
    
    
    % Overlaying x vs y data for all tags on a single plot
    figure;
    hold on;
    for tag = 1:num_tags
        plot(x_data_normalized(:, tag), y_data_normalized(:, tag), '.');
    end
    hold off;
    title('Overlay of Tags');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    legend('Tag 1', 'Tag 2', 'Tag 3'); % Add legend with appropriate tag name
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
