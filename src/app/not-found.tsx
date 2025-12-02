import { NotFoundContent } from "@/components/not-found-content"

// 禁用静态预渲染，避免构建时执行客户端上下文
export const dynamic = "force-dynamic"

export default function NotFound() {
  return <NotFoundContent />
}
