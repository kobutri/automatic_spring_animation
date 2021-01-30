# automatic_spring_animation

this package animates widgets with springs when their location changes

## Getting Started

Using this project should be fairly simple.  
Just wrap you widget in a `AnimtedSpring` and you are ready to move your widget around without jarring layout changes.  
You might need to provide a key to ensure a stable indenty.   
If you want customize the spring just supply a `SpringDescription` to the `spring` parameter.  
You can also provide a custom `shouldAnimate` callback, to customize when the the widget should be animated, just snap to the new position (same behaviour as without `AnimatedSpring`) or freeze at the current position.
