import Foundation
import RxSwift



/*:
 Copyright (c) 2019 Razeware LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */
example(of: "just, of, from") {
  let one = 1
  let two = 2
  let three = 3

  let observable1 = Observable<Int>.just(one)

  let observable2 = Observable<Int>.of(one, two, three)

  let observable3 = Observable.of([one, two, three])

  let observable4 = Observable.from([one, two, three])
}

example(of: "subscribe") {
  let one = 1
  let two = 2
  let three = 3

  let observable1 = Observable.of(one, two, three)

  observable1.subscribe(onNext: { element in
    print("element", element)
  }, onError: { _ in
    print("error")
  }, onCompleted: {() in
    print("complete")
  }, onDisposed: {() in
    print("disposed")
  })
}

example(of: "empty") {
  let observable = Observable<Void>.empty()
  observable.subscribe(onNext: {element in
    print("element: ", element)
  }, onError: { _ in
    print("error")
  }, onCompleted: {() in
    print("completed")
  }, onDisposed: {() in
    print("disposed")
  })
}

example(of: "never") {
  let observable = Observable<Any>.never()
  observable.subscribe(onNext: {element in
    print("element: ", element)
  }, onError: { _ in
    print("error")
  }, onCompleted: {() in
    print("completed")
  }, onDisposed: {() in
    print("disposed")
  })
}

example(of: "range") {
  let observable = Observable<Int>.range(start: 1, count: 10)

  observable.subscribe(onNext: {element in
    let n = Double(element)
    let fibonacci = Int(((pow(1.61803, n) - pow(0.61803, n)) /
      2.23606).rounded())
    print(fibonacci)
  })
  // Map operator
}

example(of: "map operator") {
  let observable = Observable<Int>.range(start: 1, count: 10)

  observable.map {element in
    return 2 * element
    }.subscribe(onNext: {element in
      print("element: ", element)
    })
}

example(of: "dispose") {
  let observable = Observable.of("A", "B", "C")

  let subscription = observable.subscribe({event in
    print("event: ", event)
  })
  subscription.dispose()
}

example(of: "DisposeBag") {
  let disposeBag = DisposeBag()

  let observable = Observable.of("A", "B", "C")

  observable.subscribe{
    print($0)
    }.disposed(by: disposeBag)
}

example(of: "create") {
  enum MyError: Error {
    case anError
  }

  let observable = Observable<String>.create { observer in
    print("===============create example=============")
    observer.onNext("1")
    //    observer.onError(MyError.anError)
    observer.onNext("2")
    observer.onCompleted()
    observer.onNext("3")
    return Disposables.create()
  }

  let disposeBag = DisposeBag()
  observable.subscribe(onNext: { element in
    print("element: ", element)
  }, onError: {_ in
    print("error")
  }, onCompleted: {() in
    print("complete")
  }, onDisposed: {() in
    print("disposed")
  }).disposed(by: disposeBag)
}

example(of: "deferred") {
  let disposeBag = DisposeBag()

  var flip = false
  let factory: Observable<Int> = Observable.deferred {
    print("================deferred example=====================")
    flip = !flip
    if flip {
      return Observable.of(1,2,3)
    }
    return Observable.of(4,5,6)
  }

  for _ in 0...3 {
    factory.subscribe(onNext: {
      print($0, terminator: "")
    })
      .disposed(by: disposeBag)
    print(" One loop case is end==============")
  }
}

example(of: "Single") {
  let disposeBag = DisposeBag()

  enum FileReadError: Error {
    case fileNotFound, unreadable, encodingError
  }

  func loadText(from name: String) -> Single<String> {
    return Single.create { single in
      let disposable = Disposables.create()
      guard let path = Bundle.main.path(forResource: name, ofType: "txt") else {
        single(.error(FileReadError.fileNotFound))
        return disposable
      }
      print("path: ", path)
      guard let data = FileManager.default.contents(atPath: path) else {
        single(.error(FileReadError.unreadable))
        return disposable
      }
      print("data: ", data)
      guard let contents = String(data: data, encoding: .utf8) else {
        single(.error(FileReadError.encodingError))
        return disposable
      }
      single(.success(contents))
      return disposable
    }
  }

  loadText(from: "Copyright").subscribe {
    switch $0 {
    case .success(let string):
      print(string)
    case .error(let error):
      print(error)
    }
    }.disposed(by: disposeBag)

  loadText(from: "File2").subscribe {
    switch $0 {
    case .success(let string):
      print(string)
    case .error(let error):
      print(error)
    }
    }.disposed(by: disposeBag)
}

example(of: "challenge never") {
  let observable = Observable<Any>.of(1,2,3)

  let disposeBag = DisposeBag()

  observable.do(onNext: { element in
    print("do.element: ", element)
  }, onError: { error in
    print("do.error: ", error)
  }, onCompleted: {
    print("do.complete")
  }, onSubscribe: {
    print("do.subscribe")
  }, onSubscribed: {
    print("do.subscribed")
  }, onDispose: {
    print("do.disposed")
  }).subscribe(onNext: {element in
    print("do.then.onNext.element: ", element)
  }, onError: { error in
    print("do.then.error: ", error)
  }, onCompleted: {
    print("do.then.complete")
  }, onDisposed: {
    print("do.then.disposed")
  }).disposed(by: disposeBag)
}


example(of: "Debug") {
  let observable = Observable<Any>.of(1,2,3,4)

  let disposeBag = DisposeBag()

  observable.debug().subscribe(onNext: { element in
    print("element: ", element)
  }, onError: { error in
    print("error: ", error)
  }, onCompleted: {

  }, onDisposed: {
    print("disposed")
  }).disposed(by: disposeBag)
}
