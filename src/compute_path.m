global PATH_LOAD;
global X_DIM;
global Y_DIM;
PATH_LOAD = zeros(X_DIM*Y_DIM, X_DIM*Y_DIM);
for i=1:nnode
    for j=1:node(i).connected_to_cores_num
        x_src = node(i).x;
        y_src = node(i).y;
        x_des = node(node(i).connected_to_cores(j)).x;
        y_des = node(node(i).connected_to_cores(j)).y;
        delta_x = x_des - x_src;
        delta_y = y_des - y_src;
        if (delta_x > 0)
            for k = 0:1:(delta_x-1)
                PATH_LOAD(x_src+1+X_DIM*y_src+k,x_src+1+X_DIM*y_src+k+1) = PATH_LOAD(x_src+1+X_DIM*y_src+k,x_src+1+X_DIM*y_src+k+1) + node(i).connected_to_packet_num(j);
            end
        elseif (delta_x < 0)
            for k = (delta_x+1):1:0
                PATH_LOAD(x_src+1+X_DIM*y_src+k,x_src+1+X_DIM*y_src+k-1) = PATH_LOAD(x_src+1+X_DIM*y_src+k,x_src+1+X_DIM*y_src+k-1) + node(i).connected_to_packet_num(j);
            end
        end
        if (delta_y > 0)
            for k = 0:1:(delta_y-1)
                PATH_LOAD(x_des+1+X_DIM*y_src+k*X_DIM,x_des+1+X_DIM*y_src+(k+1)*X_DIM) = PATH_LOAD(x_des+1+X_DIM*y_src+k*X_DIM,x_des+1+X_DIM*y_src+(k+1)*X_DIM) + node(i).connected_to_packet_num(j);
            end
        elseif (delta_y < 0)
            for k = (delta_y+1):1:0
                PATH_LOAD(x_des+1+X_DIM*y_src+k*X_DIM,x_des+1+X_DIM*y_src+(k-1)*X_DIM) = PATH_LOAD(x_des+1+X_DIM*y_src+k*X_DIM,x_des+1+X_DIM*y_src+(k-1)*X_DIM) + node(i).connected_to_packet_num(j);
            end
        end
    end
end