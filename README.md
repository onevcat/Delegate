# Delegate

A meta library to provide a better `Delegate` pattern described [here](https://xiaozhuanlan.com/topic/6104325798) and [here](https://onevcat.com/2020/03/improve-delegate/).

## Usage

Instead of a regular Apple's [protocol-delegate pattern](https://developer.apple.com/documentation/swift/cocoa_design_patterns/using_delegates_to_customize_object_behavior), use a simple `Delegate` object to communicate:


```swift
class ClassA {
    let onDone = Delegate<(), Void>()

    func doSomething() {
        // ...
        onDone()
    }
}

class MyClass {
    func askClassAToDoSomething() {
        let a = ClassA()
        a.onDone.delegate(on: self) { (self, _) in
            self.jobDone()
        }
        a.doSomething()
    }

    private func jobDone() {
        print("🎉")
    }
}
```
## Why

### Compare to regular delegation

`Delegate` does the same thing with much less code and compact structure. Just compare with the same work above in a formal protocol-delegate pattern.

```swift
protocol ClassADelegate {
    func doSomethingIsDone()
}

class ClassA {
    weak var delegate: ClassADelegate?

    func doSomething() {
        // ...
        delegate?.doSomethingIsDone()
    }
}

class MyClass {
    func askClassAToDoSomething() {
        let a = ClassA()
        a.delegate = self
        a.doSomething()
    }

    private func jobDone() {
        print("🎉")
    }
}

extension MyClass: ClassADelegate {
    func doSomethingIsDone() {
        self.jobDone()
    }
}
```

No one loves to write boilerplate code, do you?

### Compared to `onXXX` property

At the first glance, you may think `Delegate` is an over-work and can be replaced by a stored property like this:

```swift
class ClassA {
    var onDoneProperty: (() -> Void)?
    //...
}
```

It creates a strong holding, and I found it is really easy to create an unexpected cycle:

```swift
class MyClass {
    var a: ClassA = ClassA()

    func askClassAToDoSomething() {
        a.onDoneProperty = {
            // Retain cycle!!
            self.jobDone()
        }
    }
```

You have to remember `[weak self]` for most cases to break the cycle, it also requires you to check `self` before using it:

```swift
class MyClass {
    var a: ClassA = ClassA()

    func askClassAToDoSomething() {
        a.onDoneProperty = { [weak self] in
            guard let self = self else { return }
            self.jobDone()
        }
    }
```

Boilerplate code again! And things would become more complicated if the `onDoneProperty` needs to holds caller across multiple layers.

## How

`Delegate` holds the `target` in a `weak` way internally, and provide a "strongified" shadowed version of the target to 
you when the delegate is called. So you can get the correct memory management for free and focus on your work with no boilerplate code at all.

```swift
a.onDone.delegate(on: self) { // This `self` is the delegation target. `onDone` holds a weak ref of it.
    (self, _) in                 // This `self` is a shadowed, non-option type.
    self.jobDone()            // Using of this `self` does not create retain cycle.
}
```

To pass some parameters or receive a return type, just declared the `Delegate`'s generic types:

```swift
class DataController {
    let onShouldShowAtIndexPath = Delegate<IndexPath, Bool>()

    func foo() {
        let currentIndexPath: IndexPath = // ...
        let shouldShow: Bool = onShouldShowAtIndexPath(currentIndexPath)
        if shouldShow {
            show()
        }
    }
}

// Caller Side
dataSource.onShouldShowAtIndexPath.delegate(on: self /* : Target */ ) { (self, indexPath) in
    // This block has a type of `(Target, IndexPath) -> Bool`.
    return indexPath.row != 0
}
```

## Caution

The only caution is, please always use the shadowed `self` in the delegation block. Say, this would cause a 
regression to the old `onXXX` property way and causes a retain cycle:

```swift
a.onDone.delegate(on: self) { (_, _) in
    self.jobDone()
}
```

It seems that you can use the "same" `self`, but actually in the code above you are using the "real" strong `self`. Do not 
mark the first input parameter of block as `_` and always give it a name of `self` then you can prevent this.

## To Do

- [ ] Async support.
