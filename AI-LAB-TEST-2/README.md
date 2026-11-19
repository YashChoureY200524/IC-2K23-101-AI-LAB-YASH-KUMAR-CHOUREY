# Intelligent Travel Planner in Prolog

## Demo Video



> **Lab Test 2 | Set 9 **  
> A Prolog-based route planner that recommends the **cheapest**, **fastest**, or **shortest** route between two cities in a road network.

## Overview

The Intelligent Travel Planner represents a road network as a graph. Each city is a node, and each direct road connection is an edge containing its distance, travel time, and travel cost. Given a source city, destination city, and travel preference, the program searches available paths, calculates their totals, and recommends the best route.

## Problem Statement

A traveller wants to travel between two cities in a network where multiple routes may be available. Each route may have a different distance, travel time, and cost. The objective is to develop a Prolog program that represents at least six cities, finds possible paths, calculates route totals, and selects an optimal route based on the traveller's preference.

The planner supports:

- **Cheapest:** Minimum total cost in Rs.
- **Fastest:** Minimum total travel time in hours.
- **Shortest:** Minimum total distance in kilometres.

## Objectives

1. Represent a multi-city road network using Prolog facts.
2. Store distance, time, and cost for every connection.
3. Search paths between a source and destination.
4. Prevent cycles by tracking visited cities.
5. Calculate total distance, time, and cost for each path.
6. Compare routes and display the optimal route for the selected preference.

## Road Network

The network contains six cities: **City A, City B, City C, City D, City E, and City F**.

### Connection data

| Edge | Connection | Distance (km) | Time (hours) | Cost (Rs.) |
|---:|---|---:|---:|---:|
| 1 | City A — City B | 100 | 2 | 250 |
| 2 | City B — City F | 250 | 4 | 600 |
| 3 | City A — City C | 120 | 2 | 400 |
| 4 | City C — City F | 200 | 3 | 700 |
| 5 | City A — City D | 160 | 1 | 600 |
| 6 | City D — City F | 180 | 2 | 800 |
| 7 | City A — City E | 110 | 4 | 450 |
| 8 | City E — City F | 150 | 4 | 500 |
| 9 | City B — City C | 80 | 2 | 150 |
| 10 | City C — City D | 70 | 1 | 200 |
| 11 | City D — City E | 90 | 2 | 250 |
| 12 | City B — City E | 130 | 3 | 300 |

### Prolog representation

The connection fact uses this format:

```prolog
edge(City1, City2, Distance, Time, Cost).
```

Example:

```prolog
edge(city_a, city_b, 100, 2, 250).
```

This represents a road between City A and City B with a distance of 100 km, a travel time of 2 hours, and a cost of Rs. 250.

Roads are bidirectional. The `connected/5` rule checks both the stored direction and the reverse direction:

```prolog
connected(X, Y, D, T, C) :-
    edge(X, Y, D, T, C).

connected(X, Y, D, T, C) :-
    edge(Y, X, D, T, C).
```

## How the Program Works

1. **Input:** The user supplies a source city, destination city, and preference.
2. **Graph traversal:** DFS explores connected cities to find paths to the destination.
3. **Cycle prevention:** A visited-city list prevents the same city from appearing twice in the current path.
4. **Total calculation:** The program adds the distance, time, and cost of every edge in a completed route.
5. **Optimization:** Each route is evaluated using the selected metric: cost, time, or distance.
6. **Best-route update:** The current best result is replaced whenever a better route is found.
7. **Output:** The program displays the selected route, its totals, and the reason for selecting it.

### Core logic

| Predicate / concept | Responsibility |
|---|---|
| `edge/5` | Stores direct road connections and their metrics |
| `connected/5` | Makes roads usable in both directions |
| `find_path` | Searches for a path using DFS |
| Visited list | Prevents cycles during path search |
| `search_all` | Explores candidate paths and compares their totals |
| `best_route` | Stores the best candidate for the current search |
| `plan_travel/3` | Main predicate for requesting a route |

> The query examples assume the main predicate is named `plan_travel/3`. Keep predicate names in this README consistent with the actual source file if your implementation uses different names.

## Optimization and Tie-Breaking

The route preference determines which total is minimized:

| Preference | Primary metric | Selection rule |
|---|---|---|
| `cheapest` | Total cost | Lowest total fare |
| `fastest` | Total time | Least travel time |
| `shortest` | Total distance | Fewest kilometres |

If two routes have the same primary value, a secondary metric can be used to decide between them. For example, when two routes have the same cost, the route with the shorter travel time may be preferred. The secondary comparison order should match the implementation in the Prolog source file.

## Requirements

- [SWI-Prolog](https://www.swi-prolog.org/) installed on your computer.
- The Prolog source file, for example `travel_planner.pl`.
- A terminal or the SWI-Prolog graphical console.

## How to Run

1. Install and open SWI-Prolog.
2. Open the folder containing `travel_planner.pl`.
3. Load the program:

   ```prolog
   ?- [travel_planner].
   ```

4. Run one of the sample queries below.
5. Change the source, destination, or preference to test other routes.

If your source file has a different name, load it using its actual filename.

## Sample Queries

**Cheapest route — City A to City F**

```prolog
?- plan_travel(city_a, city_f, cheapest).
```

**Fastest route — City A to City F**

```prolog
?- plan_travel(city_a, city_f, fastest).
```

**Shortest route — City A to City F**

```prolog
?- plan_travel(city_a, city_f, shortest).
```

## Expected Test Results

The following results are calculated from the connection table above.

### Test Case 1: Cheapest route

**Query**

```prolog
?- plan_travel(city_a, city_f, cheapest).
```

**Recommended route:** City A → City B → City F

| Total cost | Total time | Total distance |
|---:|---:|---:|
| Rs. 850 | 6 hours | 350 km |

**Reason:** This route has the lowest total cost among the available routes.

### Test Case 2: Fastest route

**Query**

```prolog
?- plan_travel(city_a, city_f, fastest).
```

**Recommended route:** City A → City D → City F

| Total cost | Total time | Total distance |
|---:|---:|---:|
| Rs. 1,400 | 3 hours | 340 km |

**Reason:** This route has the lowest total travel time among the available routes.

### Test Case 3: Shortest route

**Query**

```prolog
?- plan_travel(city_a, city_f, shortest).
```

**Recommended route:** City A → City E → City F

| Total cost | Total time | Total distance |
|---:|---:|---:|
| Rs. 950 | 8 hours | 260 km |

**Reason:** This route has the lowest total distance among the available routes.

### Results summary

| Preference | Recommended route | Cost (Rs.) | Time (hours) | Distance (km) |
|---|---|---:|---:|---:|
| Cheapest | A → B → F | 850 | 6 | 350 |
| Fastest | A → D → F | 1,400 | 3 | 340 |
| Shortest | A → E → F | 950 | 8 | 260 |

## Prolog Concepts Used

- **Facts:** Store cities and road connections.
- **Rules:** Define bidirectional connections and path-search behaviour.
- **Graph representation:** Model cities as vertices and roads as edges.
- **Depth-First Search (DFS):** Explore possible paths.
- **Recursion:** Continue searching until the destination is reached.
- **Backtracking:** Explore alternative paths.
- **List processing:** Maintain the current route and visited cities.
- **Dynamic predicates:** Store and update the best route during search, if used by the implementation.
- **Arithmetic:** Calculate cumulative route cost, time, and distance.

## Suggested Repository Structure

```text
intelligent-travel-planner/
│
├── travel_planner.pl
├── README.md
├── screenshots/
│   ├── cheapest-route.png
│   ├── fastest-route.png
│   └── shortest-route.png
└── .gitignore
```

- `travel_planner.pl` — Prolog facts, rules, path search, optimization, and output.
- `README.md` — Project documentation, setup instructions, and test cases.
- `screenshots/` — Actual SWI-Prolog output screenshots.
- `.gitignore` — Files that should not be committed.

## Limitations and Future Improvements

- The network uses fixed connection data and does not retrieve live traffic or road conditions.
- The recommended route is optimal only for the data stored in the program.
- DFS may explore many simple paths as the network becomes larger.
- Future versions could accept interactive input, avoid specified cities, display multiple alternative routes, or load road data from a file.


## Conclusion

The Intelligent Travel Planner demonstrates how Prolog can solve a graph-search and route-optimization problem. It represents cities and roads as facts, searches possible paths using DFS, calculates route totals, and recommends the cheapest, fastest, or shortest route according to the traveller's preference.

---

**Lab Test:** 2  
**Set:** 9 — Intelligent Travel Planner  
**Programming Language:** Prolog  
**Roll Number:** 101
