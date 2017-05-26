# A*

[Demo](https://jcash.github.io/demos/defold/astar/DefoldExamples/index.html)

This is a first, very simple implementation of the A* algorithm.

The example extracts the information from a tile map, and uses it
to generate a shortest path between two points on the grid. 

As usual, examples like this can be expanded to further suit the needs of a project.
At its current state, it is a good foundation to start with. 

## Credits

The implementation of the A* agorithm was very much influenced by
this tutorial, by Amit Patel:
http://www.redblobgames.com/pathfinding/a-star/implementation.html#orgheadline18

The tutorial above uses a priority queue, this example uses
a heap implementation from Roland Yonaba:

https://raw.githubusercontent.com/Yonaba/Binary-Heaps/master/binary_heap.lua
