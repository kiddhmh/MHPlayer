
# MHPlayer
一句代码集成视频播放器 `Swift 3.0`；
本播放器是根据`AVPlayer`进行封装的；


## 主要功能：
  * 1.一句代码就能调用播放

  * 2.支持开始/暂停

  * 3.支持放大/缩小

  * 4.支持随屏幕旋转

  * 5.支持拖拽进度

  * 6.时间显示

  * 7.左边上下滑调节音量

  * 8.右边上下滑调节亮度

  * 9.左右滑调节播放进度

  * 10.播放屏幕保持常亮

  * 11.双击播放/暂停

## How To Use？
```Swift
mhPlayer = MHAVPlayerSDK(frame: CGRect(x: 0, y: 40, width: view.frame.size.width, height: view.frame.size.width / 2))
        mhPlayer?.mhPlayerURL = "http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"
        mhPlayer?.mhPlayerTitle = "MHPlayer"
        mhPlayer?.mhAutoOrient = true
        mhPlayer?.MHAVPlayerSDKDelegate = self
        view.addSubview(mhPlayer!)
