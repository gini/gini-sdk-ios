Working with tasks
------------------

The Gini iOS SDK makes heavy use of the concept of tasks. Tasks are convenient when you want to do a series of tasks in a 
row, each one waiting for the previous to finish. This is a common pattern when working with Gini's remote API.

The Gini iOS SDK uses [Facebook's task implementation, which is called Bolts](https://github.com/BoltsFramework/Bolts-iOS).

This document is a brief introduction how to use those tasks (and is mostly copied from Bolts' own introduction).


Tasks are a convenient way to abstract long operations
======================================================

To build a truly responsive iOS application, you must keep long-running operations off of the UI thread, and be careful 
to avoid blocking anything the UI thread might be waiting on. This means you will need to execute various operations in 
the background. In iOS 4, Apple added the possibility to use blocks in combination with the Grand Central Dispatch (GDC)
to have callbacks, thus enabling the possibility for easy background tasks. But using only callback blocks has some
great disadvantages, like the typical pyramid code when trying to do an asynchronous operation that depends on the
results of another asynchronous operation.

And the main disadvantage of simply using callbacks is that there is no form of error propagation. You have to write
error handling code in every step of the cascade and even implement your own error propagating code in order to deal
with dependent errors.

Tasks are a nice abstraction to deal with this kind of errors.

So, in short, a task is the result of a long-lasting operation. When you have a method that does some asynchronous stuff,
you usually pass in a callback block, that is executed when a result is executed. This has the disadvantages described
above. On the other side, with an ansynchronous method that uses tasks, you call the method and the method immediately
returns the `BFTask*` object, but performs its actions in the background.

Every BFTask has a method named `continueWithBlock: which takes a continuation block. A continuation is a block that will 
be executed when the task is complete. You can then inspect the task to check if it was successful and to get its result.

    [[self saveAsync:obj] continueWithBlock:^id(BFTask *task) {
      if (task.isCancelled) {
        // the save was cancelled.
      } else if (task.error) {
        // the save failed.
      } else {
        // the object was saved successfully.
        PFObject *object = task.result;
      }
      return nil;
    }];


BFTasks use Objective-C blocks, so the syntax should be pretty straightforward. Let's look closer at the types involved with an example.

    /**
     * Gets an NSString asynchronously.
     */
    - (BFTask *)getStringAsync {
      // Let's suppose getNumberAsync returns a BFTask whose result is an NSNumber.
      return [[self getNumberAsync] continueWithBlock:^id(BFTask *task) {
        // This continuation block takes the NSNumber BFTask as input,
        // and provides an NSString as output.
    
        NSNumber *number = task.result;
        return [NSString stringWithFormat:"%@", number];
      )];
    }

In many cases, you only want to do more work if the previous task was successful, and propagate any errors or 
cancellations to be dealt with later. To do this, use the continueWithSuccessBlock: method instead of continueWithBlock:.

    [[self saveAsync:obj] continueWithSuccessBlock:^id(BFTask *task) {
      // the object was saved successfully.
      return nil;
    }];

The fun part is that you can `continueWithBlock:` (and `continueWithSuccessBlock:` respectivly) more than once. If you
call it the second (or nth) time after the result is already available, the continuation block is executed immediately
and has the same result (or error) like the previous call.

As you see, tasks are not much different from callback blocks, but as an advantage they are easily chainable.

Tasks are chainable
===================

Both the `continueWithBlock:` and the `continueWithSuccessBlock:` method return another task. And this
task's result property is the return value of the continuation block of the first task:
 
    task = [sdk.getDocumentWithId:@"1234-5678-9100"] continueWithBlock:^id(BFTask *documentTask) {
        GINIDocument *document = task.result;
        return document.filename;
    }];
    
    [task continueWithBlock:^id(BFTask *documentNameTask) {
        // The result of the new task is the return value of the continuation block of the first task, thus the
        // document's filename
        myTextView.text = documentNameTask.result;
    }];

It's possible to express this construct in a more compact way:

    [[sdk.getDocumentWithId:@"1234-5678-9100"] continueWithBlock:^id(BFTask *documentTask) {
        GINIDocument *document = task.result;
        return document.filename;
    }] continueWithBlock:^id(BFTask *documentNameTask) {
        myTextView.text = documentNameTask.result;
    }];

But tasks are also a little bit magical in that they let you chain them without nesting. If you return a BFTask from the
continuation block of a `continueWithBlock:` call, then the task returned by `continueWithBlock:` will not be considered 
finished until the new task returned from the new continuation block. This lets you perform multiple actions without
incurring the pyramid code you would get with callbacks. Likewise, you can return a `BFTask` from
`continueWithSuccessBlock:`.

    [[sdk.getDocumentWithId:@"1234-5678-9100"] continueWithSuccessBlock:^id(BFTask *documentTask) {
        // documentTask.result is a `GINIDocument*`. We now call another method of the documentTaskManager which
        // also returns a `BFTask*`
        return [sdk.documentTaskManager getExtractionsForDocument:task.result];
    }] continueWithBlock:^id(BFTask *extractionsTask) {
        // This task's result property is now the dictionary with the extractions although `continueWithBlock:` was 
        // called on the first task (the documentTask)!
        NSDictionary *extractions = task.result;
        return nil;
    }];


By using such chains with tasks, a invaluable benefit is the easy error handling and error propagation.

Error handling
==============

By carefully choosing whether to call continueWithBlock: or continueWithSuccessBlock:, you can control how errors are 
propagated in your application. Using continueWithBlock: lets you handle errors by transforming them or dealing with 
them. You can think of failed tasks as kind of throwing an exception. In fact, if you throw an exception inside a 
continuation, the resulting task will be faulted with that exception.

    PFQuery *query = [PFQuery queryWithClassName:@"Student"];
    [query orderByDescending:@"gpa"];
    [[[[[self findAsync:query] continueWithSuccessBlock:^id(BFTask *task) {
      NSArray *students = task.result;
      PFObject *valedictorian = [students objectAtIndex:0];
      [valedictorian setObject:@YES forKey:@"valedictorian"];
      // Force this callback to fail.
      return [BFTask taskWithError:[NSError errorWithDomain:@"example.com"
                                                       code:-1
                                                   userInfo:nil]];
    }] continueWithSuccessBlock:^id(BFTask *task) {
      // Now this continuation will be skipped.
      PFQuery *valedictorian = task.result;
      return [self findAsync:query];
    }] continueWithBlock:^id(BFTask *task) {
      if (task.error) {
        // This error handler WILL be called.
        // The error will be the NSError returned above.
        // Let's handle the error by returning a new value.
        // The task will be completed with nil as its value.
        return nil;
      }
      // This will also be skipped.
      NSArray *students = task.result;
      PFObject *salutatorian = [students objectAtIndex:1];
      [salutatorian setObject:@YES forKey:@"salutatorian"];
      return [self saveAsync:salutatorian];
    }] continueWithSuccessBlock:^id(BFTask *task) {
      // Everything is done! This gets called.
      // The task's result is nil.
      return nil;
    }];

It's often convenient to have a long chain of success callbacks with only one error handler at the end.


Tasks and Threads / Queues
==========================

**The continuation block of a task may not necessary finish on the same thread as it started!** This will be a problem 
when you want to update or change the UI in a continuation block. Because of that, a `BFTask` also offers methods to run 
the block on other threads:

Both `continueWithBlock:` and continueWithSuccessBlock: methods have another form that takes an instance of `BFExecutor`. 
These are `continueWithExecutor:withBlock:` and `continueWithExecutor:withSuccessBlock:`. These methods allow you to
control how the continuation is executed. The default executor will dispatch to GCD, but you can provide your own
executor to schedule work onto a different thread. For example, if you want to continue with work on the UI thread:

    // Create a BFExecutor that uses the main thread.
    BFExecutor *myExecutor = [BFExecutor executorWithBlock:^void(void(^block)()) {
      dispatch_async(dispatch_get_main_queue(), block);
    }];

    // And use the Main Thread Executor like this. The executor applies only to the new
    // continuation being passed into continueWithBlock.
    [[sdk.documentTaskManager getDocumentWithId:@"1234-5678-9100"] continueWithExecutor:myExecutor withBlock:^id(BFTask *task) {
        GINIDocument* document = task.result;
        ...
    }];

For common cases, such as dispatching on the main thread, Bolts provides default implementations of `BFExecutor`. 
These include `defaultExecutor`, `immediateExecutor`, `mainThreadExecutor`, `executorWithDispatchQueue:`, and
`executorWithOperationQueue:`. For example, if you get a document and want to display the file name, you can do it with
the following code:

    // Continue on the Main Thread, using a built-in executor.
    [[sdk.documentTaskManatcher getDocumentWithId:@"1234-5678-9100"] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        GINIDocument *document = task.result;
        myTextView.text = document.filename;
    }];

@warning Always use the `[BFExecutor mainThreadExecutor]` when you want to update the UI in a task's continuation block.
Otherwise strange things may happen, such as partial screen updates, missing images, no pushing or popping of views
when using a navigation controller and so on.
