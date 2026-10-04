import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = supabaseUrl && supabaseAnonKey && !supabaseUrl.includes('YOUR_PROJECT_REF')
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null

export const hasSupabase = Boolean(supabase)

export const productFromRow = (row) => ({
  id: row.id,
  name: row.name,
  urdu: row.name,
  category: row.category,
  price: Number(row.price),
  rating: 5,
  stock: Number(row.stock_quantity),
  description: row.description || '',
  image: row.image_path ? supabase.storage.from('shop-media').getPublicUrl(row.image_path).data.publicUrl : '',
  imagePath: row.image_path || '',
  tag: row.featured ? 'Featured' : 'New',
})

export const uploadProductImage = async (file, productId) => {
  if (!supabase || !file) return { path: '', error: null }
  const extension = file.name.split('.').pop()?.toLowerCase() || 'jpg'
  const path = `products/${productId}-${crypto.randomUUID()}.${extension}`
  const { error } = await supabase.storage.from('shop-media').upload(path, file, { upsert: false, contentType: file.type })
  return { path, error }
}