// Copyright 2016 The Bennt Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

/* The Great Computer Language Shootout
   http://shootout.alioth.debian.org/

   contributed by Craig Welch
*/

use Benchmark:TreeNode;
use Benchmark:BinaryTrees;
use Math:Int;

final class TreeNode {
   
   new(Int _item) TreeNode {
      item = _item;
   }
   
   new(Int _item, TreeNode _left, TreeNode _right) TreeNode {
      fields {
         TreeNode left = _left;
         TreeNode right = _right;
         Int item = _item;
      }
   }
   
}
   
final class BinaryTrees {

	main() {
   
      Int minDepth = 4;
		Int n = 0;
      
      any args = System:Process.new().args;

		if (args.length > 0) {
         n = Int.new(args[0]);
      }

      if (minDepth + 2 > n) {
         Int maxDepth = minDepth + 2;
      } else {
         maxDepth = n;
      }
		
      Int stretchDepth = maxDepth + 1;

      Int check = checkTree(makeTree(0, stretchDepth));
      ("stretch tree of depth " + stretchDepth + "\t check: " + check).print();
      
      TreeNode longLivedTree = makeTree(0, maxDepth);
      
      Int iterations = 2.power(maxDepth);
      
      for (Int depth = minDepth; depth < stretchDepth; depth = depth + 2) {
         check = 0;
         for (Int i = 1; i < iterations + 1; i = i + 1) {
            check = check + checkTree(makeTree(i, depth)) + checkTree(makeTree(0 - i, depth));
         }
         ((iterations * 2).toString() + "\t trees of depth " + depth + "\t check:" + check).print();
         iterations = iterations / 4;
      }
      
      ("long lived tree of depth " + maxDepth + "\t check:" + checkTree(longLivedTree)).print();
      
	}
   
   makeTree(Int item, Int depth) TreeNode {
      
      if (depth > 0) {
         Int item2 = 2 * item;
         depth = depth - 1;
         return(TreeNode.new(item, makeTree(item2 - 1, depth), makeTree(item2, depth)));
      }
      
      return(TreeNode.new(item));
   }
   
   checkTree(TreeNode node) {
      if (undef(node.left)) {
         return(node.item);
      }
      return(node.item + checkTree(node.left) - checkTree(node.right));
   }

}


