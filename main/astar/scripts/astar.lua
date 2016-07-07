-- Implements the A* algorithm.
-- First base of inspiration from http://www.redblobgames.com/pathfinding/a-star/implementation.html#orgheadline18

local heap = require("main/astar/scripts/heap")

local M = {}

function M.manhattan_distance(x1, y1, x2, y2)
    local dist = math.abs(x1 - x2) + math.abs(y1 - y2)
    --print("dist:", x1, y1, "-", x2, y2, "=", dist)
    return dist
end

--- Finds the shortest path between the start and goal indices, given a grid and the costs for that grid 
-- @param grid_size A 2-tuple which is the size of the grid
-- @param costs     The costs for the individual tiles in the grid (where 0 is the lowest). An array which is grid_size[0]*grid_size[1] large 
-- @param start     The start of the search. An index into the costs array
-- @param goal      The goal of the search. An index into the costs array
-- @return A 2-tuple (came_from, cost_so_far) 
function M.astar_grid(grid_size,
                      costs,
                      start,
                      goal)
                             
    local frontier = heap()
    frontier:add(0, start)
    
    local came_from = {}
    came_from[start] = start
    local cost_so_far = {}
    cost_so_far[start] = 0
    
    local grid_width = grid_size[1]
    local grid_height = grid_size[2]
    local gx = math.floor((goal-1) % grid_width)
    local gy = math.floor((goal-1) / grid_width)
    
    local debug = false
    if debug then
        print("----------------- START")
    end
        
    while not frontier:empty() do
        prio, current = frontier:pop()
        
        if debug then
	        print("----------------- WHILE loop")
	        print("pop current", current, prio)
	    end

        if current == goal then
            break
        end
        
        -- make the coords 0 based
        local x = math.floor((current-1) % grid_width)
        local y = math.floor((current-1) / grid_width)
        
        if debug then
            print("X, Y:", x, y)
            print("----------------- for loop")
        end
        
        local next_coords = { {x, y-1}, {x-1, y}, {x+1, y}, {x, y+1} }
        for i = 1, 4 do
            local nx = next_coords[i][1]
            local ny = next_coords[i][2]
            
            if debug then
                print("  ----------------- iter " .. tostring(i))
            end
            
            local next = ny * grid_width + nx
            
            if debug then
                print("nx, ny", nx, ny, grid_width, grid_height, "next", next)
            end
            
            if nx >= 0 and nx < grid_width and ny >= 0 and ny < grid_height then
                local next = ny * grid_width + nx + 1
                local current_cost = cost_so_far[current]
            
                if debug then    
                    print("move", current, "->", next)
                end
                local current_cost = cost_so_far[current]
                local level_cost = costs[next]
                local new_cost = current_cost + costs[next]
                local next_cost = cost_so_far[next]
                
                if debug then
	                print("current_cost", current_cost)
	                print("tile_cost", costs[next])
	                print("new_cost", new_cost)
	                print("next_cost", cost_so_far[next])
	            end
                
                if next_cost == nil or new_cost < next_cost then
                    cost_so_far[next] = new_cost
                    local priority = new_cost + M.manhattan_distance(nx, ny, gx, gy)
	                if debug then
	                    print("push", next, priority, " (came from", current, ")")
	                end
                    frontier:add(priority, next)
                    came_from[next] = current
                end
            end
        end
        if debug then
            print("----------------- end for loop")
        end
        
    end
    
    return came_from, cost_so_far
end

return M
