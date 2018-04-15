# MIPS Iterative Quicksort with Insertion

This is a sorting algorithm implemented in MIPS assembly as a University assignment. It's written in MARS 4.2 with support for delayed branching. 

Some of the optimizations we implemented were:
- Using iteration instead of recursion, this reduced stack overhead.
- Only using quicksort partly in order to generate a nearly sorted list, which then is sorted using insertion sort.
- Sampling three values and using the median as pivot.
- Avoiding unnecessary null operations.
- Inlining all subroutines.

These are some nice references we used:<br>
https://www.geeksforgeeks.org/iterative-quick-sort/<br>
https://en.wikipedia.org/wiki/Quicksort<br>
<br>
**Warning:** Ugly code. We prioritized optimization since this was a competition, so all subroutines have been inlined, and register conventions have been ignored.
