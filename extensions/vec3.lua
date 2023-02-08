function Vec3:DistanceSq2D(to)
  local from = Vec2(self.x, self.y)
  return from:DistanceSq(Vec2(to.x, to.y))
end
