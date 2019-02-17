import Foundation

typealias CompletionHandler<T> = Consumer<Producer<T>>

typealias Consumer<T> = (T) -> Void
typealias Producer<T> = () -> T
typealias Runnable = () -> Void
