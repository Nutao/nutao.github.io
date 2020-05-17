---
title: Golang错误与异常处理
date: 2020-05-17 20:10:46
tags:
    - Golang
categories:
    - Golang
---


Golang错误类型使用error进行处理，而异常通常使用panic-recover进行处理。
<!-- more -->

## 1. 使用error处理错误
error类型是一个接口类型，自定义的错误类型也必须实现为 error 接口，可以通过 Error() 获取到具体的错误信息而不用关心错误的具体类型。
它的定义：

```go
type error interface {
    Error() string}
```

### 例子

```go
func testSqrt(f float64)(float64, error){    
    if f < 0 {         
        return 0, errors.New("请输入正数")    
    }else {
        sqrt := math.Sqrt(f)         
        return sqrt,nil    
    }
}
```
使用标准库的 `fmt.Errorf` 和 `errors.New` 可以方便的创建 error 类型的变量。

### 使用场景
> 预定义错误值

预定义全局的错误变量，方便在后续逻辑中进行对应的error判断。

```golang

var (
    ErrInventoryInsufficient      = errors.New("product inventory insufficient")
    ErrProductSalesTerritoryLimit = errors.New("product sales torritory limit")
)


if err != nil {
        switch err {
            case service.ErrInventoryInsufficient:      // handling
            case service.ErrProductSalesTerritoryLimit: // handling
        }
 }
```

> 自定义错误类型

自定义结构体错误类型，通过传值的方式构造错误信息。至少实现`Error()`方法。
```golang
type HTTPError struct {
    Code        int
    Description string
}

func (h *HTTPError) Error() string {
    return fmt.Sprintf("status code %d: %s", h.Code, h.Description)}
    
func request() error {
    return &HTTPError{404, "not found"}}

func main() {
    err := request()

    if err != nil {
        // an error occured
        if err.(*HTTPError).Code == 404 {
            // handle a "not found" error
        } else {
            // handle a different error
        }
    }

}
```
## 2. panic & recover 处理异常
panic / recover 机制控制流作用在整个 goroutine 的调用栈。
- 当 goroutine 执行到 panic 时，控制流开始在当前 goroutine 的调用栈内向上回溯(unwind)并执行每个函数的 defer。
- 如果 defer 中遇到 recover 则回溯停止
- 如果执行到 goroutine 最顶层的 defer 还没有 recover ，运行时就输出调用栈信息然后退出。

如果要使用 recover 避免 panic 导致进程挂掉，`recover 必须要放到 defer 里`。


### 使用场景
1. 发生严重错误(critical error)必须让进程退出。

当错误无法恢复导致程序无法执行或继续执行会出现不可预知的行为时，可以用panic。例如：启动参数不符合预期等。

2. 快速退出错误处理。

类似于try-catch逻辑，使用panic让顶层的revocer来处理相关的错误。但是尽量在包内处理，避免复杂逻辑。

### 例子：

```golang 
defer func() {
    if err2 := recover(); err2 != nil {
        debug.PrintStack()
        statusCode = http.StatusInternalServerError
        err = fmt.Errorf("%v",err2)
    }
}()

c := new(dns.Client)
c.Net = "udp4"
r, rtt, err := c.Exchange(m, nameserver)

if err != nil {
    logs.Error(err)
    panic(err)
} else if !r.Response {
    err = errors.New("did not get any response")
    logs.Error(err)
    panic(err)
}
```
