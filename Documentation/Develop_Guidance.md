# Develop Guidance
- This document introduces the development guidance for this project. 
- You should read the guidance carefully before you start to develop. 
- You should follow the guidance to develop this project, any violation of this guidance will not be accepted in the pull request.

## Coding Language
This project is written in Swift
### SwiftUI
    

### Model - View - ViewModel (MVVM)
1. Model

2. ViewModel

3. View

## Code Style
- Class


- Function
  - Function should be short, the length should be less than 30 lines 
  - Function should do only one thing
  - Input/Output:
  - Document:
  
- Naming
  - Variable name: camelCase
  - Function name: camelCase
  - Class name: PascalCase

- Comments
    - Comments should be used to explain the 

  
- Format
  - Formatter: Xcode default formatter
  - Line length: 120
  
- Git
  - Commit:
  - Branch:
  - Pull Request:
  - Code Review:
  - Merge:
  - Publish:
  - Remote:





## Test driven development


## Clean Code
    - [Clean Code](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882)
    - [Clean Code Swift](
    
    
## Version
    在软件开发中，术语如“金丝雀”（Canary）、“Dogfood”、“Beta”和“Alpha”指的是不同阶段的软件版本，每个阶段都有特定的测试目的和目标用户群。下面是每个术语的一般含义：
    
1. **Alpha（阿尔法）**:
   - Alpha 版本是早期的软件版本，通常是功能尚未完全开发完成的版本。
   - 它主要用于内部测试，目的是快速迭代和识别大的问题或缺陷。
   - Alpha 测试通常是不公开的，限于开发者和内部测试人员。

2. **Beta（贝塔）**:
   - Beta 版本是在软件开发过程中较为成熟的阶段，主要功能通常都已经实现，并且可以进行公开测试。
   - Beta 测试可以是封闭的（限定的测试用户群）或者是开放的（对所有感兴趣的用户开放）。
   - Beta 版本用于收集用户反馈，修复在实际使用中发现的缺陷，优化性能和用户体验。

3. **Canary（金丝雀）**:
   - Canary 版本得名于“矿井里的金丝雀”（canary in a coal mine），是一种实践，指在全面推出更新前先对一小部分用户推出。
   - 如果这小部分用户遇到问题，那么问题被限制在较小的范围内，并且可以在影响到更多用户前回滚更改。
   - 这是一种渐进式部署策略，有时候用于生产环境，用来测试真实世界的性能和稳定性。

4. **Dogfood（内部使用）**:
   - “Dogfooding”是指公司让其员工使用自家开发的产品或软件。
   - 这种做法的目的是让团队在日常工作中自然而然地发现问题和不足。
   - 这是一种质量保证和用户体验的改进方法，因为员工更有可能遇到并报告问题。

通常，软件的开发周期从Alpha开始，随后进入Beta阶段，最终发布正式（Production）版本。Canary和Dogfood策略可以在整个开发周期中任何时间点使用，作为持续的质量保证措施。Dogfooding通常发生在内部，而Canary通常发生在软件已经相对稳定，准备进行更广泛测试或正式发布前的最后阶段。
