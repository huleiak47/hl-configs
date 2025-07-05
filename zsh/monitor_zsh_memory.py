#!/usr/bin/env python3
import psutil
import time

# --- 配置 ---
PROCESS_NAME = "zsh.exe"
# 内存限制（单位：GB）
MEMORY_LIMIT_MB = 128
# 将GB转换为字节
MEMORY_LIMIT_BYTES = MEMORY_LIMIT_MB * 1024 * 1024
# 检查时间间隔（单位：秒）
CHECK_INTERVAL_SECONDS = 10


def find_and_kill_processes():
    """查找并结束超出内存限制的进程"""
    # 遍历所有正在运行的进程
    # 'pid', 'name', 'memory_info' 是为了提高效率，一次性获取所需信息
    for proc in psutil.process_iter(["pid", "name", "memory_info"]):
        try:
            # 检查进程名称是否匹配
            if proc.info["name"] == PROCESS_NAME:
                memory_usage = proc.info["memory_info"].rss  # rss 是实际使用的物理内存

                # 如果内存使用超过限制
                if memory_usage > MEMORY_LIMIT_BYTES:
                    memory_usage_mb = memory_usage / (1024 * 1024)
                    print(
                        f"警告：进程 {PROCESS_NAME} (PID: {proc.info['pid']}) 使用了 {memory_usage_mb:.2f} MB 内存，超过限制。"
                    )
                    print(f"正在强制结束进程 {proc.info['pid']}...")
                    proc.kill()  # 强制结束进程
                    print(f"进程 {proc.info['pid']} 已被结束。")

        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            # 如果进程在检查时已经不存在或无法访问，则忽略
            pass


if __name__ == "__main__":
    print(f"开始监控进程 '{PROCESS_NAME}'...")
    print(f"内存限制: {MEMORY_LIMIT_MB} MB")
    print(f"检查间隔: {CHECK_INTERVAL_SECONDS} 秒")
    print("按 Ctrl+C 停止脚本。")

    try:
        while True:
            find_and_kill_processes()
            time.sleep(CHECK_INTERVAL_SECONDS)
    except KeyboardInterrupt:
        print("\n脚本已停止。")
    except Exception as e:
        print(f"发生未知错误: {e}")
