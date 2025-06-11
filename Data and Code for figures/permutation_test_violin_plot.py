import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats
import itertools

# 设置中文字体
plt.rcParams["font.family"] = ["SimHei", "WenQuanYi Micro Hei", "Heiti TC"]
plt.rcParams['axes.unicode_minus'] = False  # 解决负号显示问题


def read_csv_file(file_path):
    """读取CSV文件并返回DataFrame"""
    try:
        df = pd.read_csv(file_path)
        print(f"成功读取数据，共{df.shape[0]}行，{df.shape[1]}列")
        return df
    except Exception as e:
        print(f"读取文件时出错: {e}")
        return None


def permutation_test(data1, data2, n_permutations=10000):
    """
    执行置换检验

    参数:
    data1, data2: 要比较的两组数据
    n_permutations: 置换次数

    返回:
    p_value: 置换检验得到的p值
    """
    # 计算实际观察到的均值差异
    observed_diff = np.mean(data1) - np.mean(data2)

    # 合并两组数据
    combined = np.concatenate([data1, data2])
    n1 = len(data1)
    count = 0

    # 执行置换
    for _ in range(n_permutations):
        # 随机打乱数据
        np.random.shuffle(combined)
        # 分割为两组
        perm_group1 = combined[:n1]
        perm_group2 = combined[n1:]
        # 计算置换后的均值差异
        perm_diff = np.mean(perm_group1) - np.mean(perm_group2)
        # 如果差异大于等于观察到的差异，计数加1
        if abs(perm_diff) >= abs(observed_diff):
            count += 1

    # 计算p值
    p_value = count / n_permutations
    return p_value


def plot_comparison_violins(file_path, y_label, target_col_idx=3):
    """
    读取CSV文件，绘制小提琴图比较各列与目标列，并标记显著性

    参数:
    file_path: CSV文件路径
    y_label: 纵轴标题
    target_col_idx: 目标列的索引(默认为第4列，索引为3)
    """
    # 读取数据
    df = read_csv_file(file_path)
    if df is None:
        return None

    # 检查数据是否足够
    if df.shape[1] < 5:
        print("数据列数不足，至少需要5列数据")
        return None

    # 重命名列为Model1到Model5
    df.columns = [f'Model{i + 1}' for i in range(df.shape[1])]
    target_col = df.columns[target_col_idx]

    # 获取要比较的列
    columns_to_compare = [i for i in range(df.shape[1]) if i != target_col_idx]

    # 创建画布
    fig, axes = plt.subplots(1, len(columns_to_compare), figsize=(5 * len(columns_to_compare), 6))
    if len(columns_to_compare) == 1:
        axes = [axes]  # 确保axes是可迭代的

    results = {}

    for i, col_idx in enumerate(columns_to_compare):
        col = df.columns[col_idx]

        # 执行置换检验
        p_value = permutation_test(df[col].dropna(), df[target_col].dropna())
        results[f'{col} vs {target_col}'] = p_value

        # 绘制小提琴图
        sns.violinplot(data=df[[col, target_col]], ax=axes[i], inner=None, palette="pastel")

        # 添加散点图，使用抖动位置
        sns.stripplot(data=df[[col, target_col]], ax=axes[i],
                      size=4, color='black', alpha=0.6, jitter=0.1)

        # 添加显著性标记
        y_max = max(df[col].max(), df[target_col].max())
        y_range = y_max - min(df[col].min(), df[target_col].min())
        height = y_range * 0.05

        # 根据p值添加显著性标记
        if p_value < 0.001:
            sig_label = '***'
        elif p_value < 0.01:
            sig_label = '**'
        elif p_value < 0.05:
            sig_label = '*'
        else:
            sig_label = 'n.s.'

        # 绘制显著性标记线
        axes[i].plot([0, 0, 1, 1], [y_max + height, y_max + 2 * height, y_max + 2 * height, y_max + height], lw=1.5,
                     c='black')
        axes[i].text(0.5, y_max + 2.2 * height, sig_label, ha='center', va='bottom', fontsize=12)

        # 设置标题和标签
        axes[i].set_title(f'{col} vs {target_col}\np={p_value:.4f}')
        axes[i].set_xlabel('组别')
        axes[i].set_ylabel(y_label)

    plt.tight_layout()
    plt.show()

    return results


