function checkerboard = MakeCheckerboard_sq(chb_x,chb_y, Square_size)

% clear all;
% Square_size = 40;
% [chb_x,chb_y] = [4, 4];

Checkerboard_size = [chb_x,chb_y];
Board_size = Checkerboard_size * Square_size;
Board = zeros(Board_size);

for i = 1:Checkerboard_size(1)
    for j = 1:Square_size
        if mod(i,2) ==0;
            Board(j+Square_size*(i-1),:) = Board(j+Square_size*(i-1),:)+1;
%             Board(:, j+Square_size*(i-1)) = Board(:, j+Square_size*(i-1))*(-1);
        else
            Board(j+Square_size*(i-1),:) = Board(j+Square_size*(i-1),:)-1;
        end
    end
end

for i = 1:Checkerboard_size(2)
    for j = 1:Square_size
        if mod(i,2) ==0;
            Board(:, j+Square_size*(i-1)) = Board(:, j+Square_size*(i-1))*(-1);
        end
    end
end
checkerboard = Board;
% figure;
% imshow(checkerboard);

end