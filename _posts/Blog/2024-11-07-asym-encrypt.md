---
title: 非对称加密算法
subtitle: RSA探讨
date: 2024-11-07 17:16:13 +0800
categories:
  - blog
tags:
  - Blog
published: true
math: true
image:
---
* content
{:toc}


# 关于加密算法RSA浅析

## 什么是非对称加密？
非对称加密，对应对称加密。用两个不同的密钥才可以加密解密信息。

公钥可以放在网上，私钥保密就可以。

| 对称加密 | DES, AES, 3DES                  |
| -------- | ------------------------------- |
| 非对称密 | RSA, ECC                        |
| 哈希算法 | MD（消息摘要），SHA（安全哈希） |

## Preliminary
以下几个不去证明的数学原理

**互质关系**：两个数除了1 没有公因子。

**欧拉函数**：$\varphi(n)$ 为在小于等于n的正整数中有多少个数与n互质。
> 欧拉函数的一些性质：
> 
> 	1.  $\varphi(1) = 1$   
> 	2. 如果n为质数，则 $\varphi(n) = n - 1$   
> 	3. 如果n为质数的某一个次方，即 $n = p^k$ , 则 $\varphi(p^k) = p^k - p^{k-1}$，与n存在公因子的元素中，只有p的某次方   
> 	4. 如果n为两个互质整数的积，即 $n = p \times q$ ，则 $\varphi(n) = \varphi(p) * \varphi(q)$ 。证明需要用到*中国剩余定理*，不做介绍，其实并不难。   
> 	5. 如果 $n = p_1^{k1} \times p_2^{k2} ...$，则 $\varphi(n) = \varphi(p_1^{k1}) \times ...$    
> 


**欧拉定理**：如果两个数 a 和 n 互质，则 $a^{\varphi(n)} \equiv 1 (mod \ n)$ ，此处证明过于复杂，不做介绍。特殊情况费马小定理 p 是质数，$a^{p-1} \equiv 1 (mod \ n)$ .

**模反元素**：如果 $a*b \equiv 1 (mod \ n)$ ，则称a和b是在\*运算上的模反元素。

用欧拉定理可以得到得到，若 $b = a^{\varphi(n) - 1}$ ，则 $a * b \equiv 1 (mod \ n)$，得到b是a的模反元素。



## 算法的流程


```bash
Select p, q                   # p and q both prime, p != q
Calculate n = p * q
Calculate φ(n) = (p - 1) * (q - 1)

Select integer e              # e is relatively primte to φ(n)
Calculate d                   # (d * e) mod n = 1

Public key                    # PU = {e, n}
Private key                   # PR = {d, n}

```


加密

```bash 
Plaintext M                 # M << n
Ciphertext C                # C = M^{e} mod n

```


解密

```bash
Ciphertext C
Plaintext M                  # M = C^{d} mod n

```




## 有效性证明

需要证明

$$
 (M^{e}\quad [mod \ n])^d \quad [mod \ n] \equiv M
$$

**第一步**：

$$
 (a \quad mod \quad n )^b \quad mod \quad n = 
a^b \quad mod \quad n  \\
$$

证明：
$$
(k * n + j) ^b \quad [mod \ n] = (k*n)^b + b(k*n)^{b-1}*j + \cdots \quad [mod \ n] = j^b \quad [mod \ n]
$$

**第二步**：

$$
\begin{array}{c}
(M^e [mod \ n])^d [mod\ n] =& M^{ed} \ [mod n] \\
=& M^{k*\varphi(n) + 1} \ [mod\ n] \\
=& (M^{k*\varphi(n)} * M ) [mod \ n] \\
\end{array}
$$


又因为，n是两个较大的质数的乘积，而 $M \ll p, q \ll n$ ，所以M与n互质，则有 $M^{\varphi(n)} \equiv 1[mod \ n]$ ，即 $M^{\varphi(n)} = i*n + 1$ 。所以有：

$$
\begin{array}{c}
(M^e [mod \ n])^d [mod\ n] =& (M^{k*\varphi(n)} * M ) [mod \ n] \\
						=& \left \{(i * n + 1)^k * M \right \} [mod \ n] \\
						=& M[mod \ n] \\
						=& M
\end{array}
$$


## 难以破解证明


算法基于的假设：p * q --> n 容易，n --> {p, q}非常难。是位数的指数时间复杂度算法。

通常私钥和公钥都到2048位数，存储或者计算成本都要到 $2^{2048}$ 往上了。


## Python 代码理解

**密钥生成**


```python
from Crypto import Random
from Crypto.PublicKey import RSA

# 伪随机数生成器
random_generator = Random.new().read
# rsa算法生成实例
rsa = RSA.generate(1024, random_generator)

# master的秘钥对的生成
private_pem = rsa.exportKey()
with open('master-private.pem', 'wb') as f:
    f.write(private_pem)

public_pem = rsa.publickey().exportKey()
with open('master-public.pem', 'wb') as f:
    f.write(public_pem)


# ghost的秘钥对的生成
private_pem = rsa.exportKey()
with open('ghost-private.pem', 'wb') as f:
    f.write(private_pem)

public_pem = rsa.publickey().exportKey()
with open('ghost-public.pem', 'wb') as f:
f.write(public_pem)

```


加密解密


```python
from Crypto.PublicKey import RSA
from Crypto.Cipher import PKCS1_OAEP

import base64

def encrypt(text):
	with open('ghost-public.pem') as f:
		rsa_key = RSA.importKey(f.read())
		cipher = PKCS1_OAEP.new(rsa_key)
		encrypt_text = base64.b64encode(cipher.encrypt(text.encode("utf-8")))

	return encrypt_text.decode("utf-8")

def decrypt(encrypt_text):
	with open('ghost-private.pem') as f:
		rsa_key = RSA.importKey(f.read())
		cipher = PKCS1_OAEP.new(rsa_key)
		text = cipher.decrypt(base64.b64decode(encrypt_text))
	
	return text.decode("utf-8")

if __name__ == "__main__":
	text = 'hello ghost, this is a plian text'
	encrypt_text = encrypt(text)
	print(encrypt_text)
	decrypt_text = decrypt(encrypt_text)
	print(decrypt_text)
```


> - 在使用RSA加密时，推荐使用PKCS1_OAE，PKCS1_V1_5可用于兼容老代码，但已不推荐使用。PKCS1_OAE是RSA的改进版本，防止信息过短被暴力破解
> - RSA可以加密的单段数据长度受key的长度所限制，大量数据需分段加密
{: .prompt-warning }


## 补充

对于公钥被冒充问题，需要对发放公钥的地址进行CA认证。

关于是否绝对安全，还是社会工程学的问题。即使技术如何如何，都避免不了最开始建立信任的问题。如果一开始就在谎言之中，就像「楚门的世界」一样，那也xxx。

